import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/app_colors.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/app_images.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/local_strings.dart';
 import 'package:flutter_nobrokeragefortenants/core/utils/preferences.dart';
 import 'package:flutter_nobrokeragefortenants/models/subscription/requirement_model.dart';
 import 'package:flutter_nobrokeragefortenants/screens/auth/login/login_screen.dart';
 import 'package:flutter_nobrokeragefortenants/services/api/api_endpoints.dart';
 import 'package:flutter_nobrokeragefortenants/services/api/subscription_api.dart';
 import 'package:flutter_nobrokeragefortenants/services/subscription_gate.dart';
 import 'package:flutter_nobrokeragefortenants/widgets/customize_bottom_tab.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  int step = 0;
  bool isReviewing = false;
  bool isSubmitting = false;
  bool isLoadingRequirement = true;
  late final Razorpay _razorpay;
  String? requirementId;
  String purpose = '';
  String state = '';
  String city = '';
  String area = '';
  String propertyType = '';
  String furnishing = '';
  String format = '';
  String floor = '';
  String sizeType = 'Sqft';
  final pincodeController = TextEditingController();
  final sizeController = TextEditingController();
  final budgetController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _loadExistingRequirement();
  }

  Future<void> _loadExistingRequirement() async {
    try {
      final requirement = await SubscriptionApi.getRequirement(
        context: context,
      );
      if (!mounted) return;
      if (requirement != null && requirement.id.isNotEmpty) {
        _populateRequirement(requirement);
      }
    } catch (_) {
      // A missing requirement opens the same wizard with empty defaults.
    } finally {
      if (mounted) setState(() => isLoadingRequirement = false);
    }
  }

  void _populateRequirement(UserRequirement requirement) {
    requirementId = requirement.id;
    purpose =
        requirement.propertyPurpose.isEmpty
            ? purpose
            : requirement.propertyPurpose;
    propertyType =
        requirement.propertyType.isEmpty
            ? propertyType
            : requirement.propertyType;
    floor = requirement.floor;
    furnishing =
        requirement.furnished.isEmpty ? furnishing : requirement.furnished;
    format = _displayFormat(requirement.format);
    state = requirement.state.isEmpty ? state : requirement.state;
    city = requirement.city.isEmpty ? city : requirement.city;
    area = requirement.area.isEmpty ? area : requirement.area;
    sizeController.text =
        requirement.size.isEmpty ? sizeController.text : requirement.size;
    pincodeController.text =
        requirement.pincode.toString() == '0'
            ? pincodeController.text
            : requirement.pincode.toString();
    budgetController.text =
        requirement.priceRange.toString() == '0'
            ? budgetController.text
            : requirement.priceRange.toString();
    if (mounted) setState(() {});
  }

  String _displayFormat(String value) {
    if (value.isEmpty) return format;
    final normalized = value.replaceAll(' ', '').toUpperCase();
    if (normalized == '1BHK') return '1 BHK';
    if (normalized == '2BHK') return '2 BHK';
    if (normalized == '3BHK') return '3 BHK';
    if (normalized == '4BHK') return '4 BHK';
    if (normalized == '5+BHK') return '5+ BHK';
    return value;
  }

  @override
  void dispose() {
    _razorpay.clear();
    pincodeController.dispose();
    sizeController.dispose();
    budgetController.dispose();
    super.dispose();
  }

  int get budget => int.tryParse(budgetController.text) ?? 0;
  int get amount => purpose == 'Commercial' ? (budget / 2.5).round() : (budget / 5).round();

  Future<void> _startPayment() async {
    if (requirementId == null || requirementId!.isEmpty) {
      throw Exception('Requirement was not saved');
    }
    final order = await SubscriptionApi.createPaymentOrder(
      context: context,
      amount: amount,
      requirementId: requirementId!,
    );
    _razorpay.open({
      'key': AppEndpoints.razorpayKeyId,
      'amount': order['amount'],
      'currency': order['currency'] ?? 'INR',
      'order_id': order['id'],
      'name': 'Property Rental Service',
      'description': 'Payment for $purpose property requirement',
      'theme': {'color': '#265953'},
    });
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if (requirementId == null || response.orderId == null || response.paymentId == null || response.signature == null) {
      Fluttertoast.showToast(msg: 'Payment response was incomplete. Please contact support.');
      return;
    }
    try {
      final subscription = await SubscriptionApi.verifyPayment(
        context: context,
        requirementId: requirementId!,
        orderId: response.orderId!,
        paymentId: response.paymentId!,
        signature: response.signature!,
        amount: amount,
      );
      if (!mounted) return;
      if (!subscription.isActive) throw Exception('Subscription is not active');
      await Prefs.setBool('activeSubscription', true);
      await Prefs.setString(LocalStrings.subscriptionStart, subscription.startDate?.toIso8601String() ?? '');
      await Prefs.setString(LocalStrings.subscriptionEnd, subscription.endDate?.toIso8601String() ?? '');
      await Prefs.setString(LocalStrings.subscriptionPurpose, subscription.propertyPurpose);
      await SubscriptionGate.refresh(context);
      if (!mounted) return;
      Fluttertoast.showToast(msg: 'Payment successful. Subscription activated.');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const PrimaryBottomTab()),
        (_) => false,
      );
    } catch (_) {
      if (mounted) Fluttertoast.showToast(msg: 'Payment verification failed. Please contact support.');
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (!mounted) return;
    setState(() => isSubmitting = false);
    Fluttertoast.showToast(msg: 'Payment failed. Please try again.');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(msg: 'External wallet selected. Complete payment there.');
  }

  Future<void> _logout() async {
    await Prefs.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MyLoginScreen()),
      (_) => false,
    );
  }

  Future<void> _submitRequirement() async {
    if (isSubmitting) return;
    setState(() => isSubmitting = true);
    final body = {
      'propertyPurpose': purpose,
      'propertyType': propertyType,
      'floor': floor,
      'furnished': furnishing,
      'format': format.replaceAll(' ', ''),
      'state': state,
      'city': city,
      'area': area,
      'size': sizeController.text.trim(),
      'priceRange': budget,
      'scheme': '',
      'pincode': int.tryParse(pincodeController.text.trim()) ?? 0,
      'amount': amount,
    };
    try {
      if (requirementId == null || requirementId!.isEmpty) {
        final response = await SubscriptionApi.submitRequirement(
          context: context,
          data: body,
        );
        requirementId = _extractRequirementId(response);
      } else {
        await SubscriptionApi.updateRequirement(
          context: context,
          id: requirementId!,
          data: body,
        );
      }
      await _startPayment();
    } catch (error) {
      if (mounted) {
        Fluttertoast.showToast(msg: 'Unable to save requirement or start payment');
      }
      debugPrint('Requirement/payment error: $error');
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  String? _extractRequirementId(dynamic response) {
    if (response is! Map) return null;
    final map = Map<String, dynamic>.from(response);
    final data = map['data'] ?? map['requirement'];
    if (data is Map) {
      return (data['_id'] ?? data['id'])?.toString();
    }
    return (map['_id'] ?? map['id'])?.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffaf9f6),
      body: SafeArea(
        child: Column(
          children: [
            _topBar(),
            if (!isReviewing) _progress(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                child: _stepContent(),
              ),
            ),
            _footerActions(),
          ],
        ),
      ),
    );
  }

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 4),
      child: Row(
        children: [
          if (step > 0)
            IconButton(
              onPressed:
                  () => setState(() {
                    if (isReviewing) {
                      isReviewing = false;
                    } else {
                      step--;
                    }
                  }),
              icon: const Icon(Icons.arrow_back, color: AppColors.primary),
            )
          else
            const SizedBox(width: 48),
          const Spacer(),
          Text(
            'Step ${step + 1} of 4',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          Image.asset(
            AppIcons.icApp,
            height: 42,
            width: 92,
            fit: BoxFit.contain,
          ),
          IconButton(
            onPressed: _logout,
            tooltip: 'Logout',
            icon: const Icon(Icons.logout, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _progress() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 38, vertical: 8),
      child: Row(
        children: List.generate(4, (index) {
          final active = index <= step;
          return Expanded(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 15,
                  backgroundColor: active ? AppColors.primary : Colors.white,
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: active ? Colors.white : AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (index < 3)
                  Expanded(
                    child: Container(
                      height: 2,
                      color:
                          index < step
                              ? AppColors.primary
                              : const Color(0xffd9dfdc),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _stepContent() {
    if (isLoadingRequirement) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 100),
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (isReviewing) return _reviewStep();
    switch (step) {
      case 0:
        return _choiceStep(
          title: 'What is the purpose of the property?',
          subtitle:
              'Please select the primary purpose of the property you need.',
          options: ['Commercial', 'Residential'],
          selected: purpose,
          onSelected: (value) => setState(() => purpose = value),
        );
      case 1:
        return _locationStep();
      case 2:
        return _detailsStep();
      default:
        return _budgetStep();
    }
  }

  Widget _choiceStep({
    required String title,
    required String subtitle,
    required List<String> options,
    required String selected,
    required ValueChanged<String> onSelected,
  }) {
    return Column(
      children: [
        _heading(title, subtitle),
        const SizedBox(height: 26),
        Row(
          children:
              options
                  .map(
                    (option) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: _choiceCard(
                          option,
                          option == 'Commercial'
                              ? Icons.business_outlined
                              : Icons.home_outlined,
                          selected == option,
                          () => onSelected(option),
                        ),
                      ),
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }

  Widget _choiceCard(
    String label,
    IconData icon,
    bool selected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 220,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary : const Color(0xffe2e7e4),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: selected ? Colors.white : AppColors.secondary,
            ),
            const SizedBox(height: 18),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.primary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              label == 'Commercial'
                  ? 'For business, office or shop use.'
                  : 'For living, family or personal use.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.gray500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _locationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading(
          'Where do you need the property?',
          'Please enter the location details.',
        ),
        const SizedBox(height: 24),
        _field('State', state, [
          'Gujarat',
          'Maharashtra',
          'Karnataka',
        ], (value) => setState(() => state = value!)),
        _field('City', city, [
          'Ahmedabad',
          'Mumbai',
          'Bangalore',
        ], (value) => setState(() => city = value!)),
        _field('Area / Locality', area, [
          'SG Highway',
          'Bandra West',
          'Whitefield',
        ], (value) => setState(() => area = value!)),
        _input('Pincode', pincodeController, TextInputType.number),
      ],
    );
  }

  Widget _detailsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading(
          'Tell us more about the property you want',
          'Select property type, furnishing and configuration.',
        ),
        const SizedBox(height: 20),
        _sectionLabel('Type of Property'),
        _chips(
          ['Bungalow', 'Apartment', 'Villa', 'Plot', 'Other'],
          propertyType,
          (value) => setState(() => propertyType = value),
        ),
        _sectionLabel('Furnishing'),
        _chips(
          ['Unfurnished', 'Furnished', 'Semi-furnished'],
          furnishing,
          (value) => setState(() => furnishing = value),
        ),
        _sectionLabel('Configuration (BHK)'),
        _chips(
          ['1 BHK', '2 BHK', '3 BHK', '4 BHK', '5+ BHK'],
          format,
          (value) => setState(() => format = value),
        ),
      ],
    );
  }

  Widget _budgetStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading(
          'Share size and budget for better matches',
          'Help us understand your requirement better.',
        ),
        const SizedBox(height: 20),
        _sectionLabel('Size type'),
        _chips(
          ['Sqft', 'Vigha', 'SqYard'],
          sizeType,
          (value) => setState(() => sizeType = value),
        ),
        _input('Size', sizeController, TextInputType.number),
        _input('Budget', budgetController, TextInputType.number),
        const SizedBox(height: 18),
        _summary(),
      ],
    );
  }

  Widget _reviewStep() {
    return Column(
      children: [
        _heading(
          'Review Your Requirement',
          'Please review your requirement details before submitting.',
        ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xffe2e7e4)),
          ),
          child: Column(
            children: [
              _reviewRow(Icons.home_outlined, 'Purpose', purpose),
              _reviewRow(
                Icons.location_on_outlined,
                'Location',
                '$city, $state\n$area, ${pincodeController.text}',
              ),
              _reviewRow(
                Icons.home_work_outlined,
                'Property Type',
                propertyType,
              ),
              _reviewRow(Icons.weekend_outlined, 'Furnishing', furnishing),
              _reviewRow(Icons.tune, 'Configuration', format),
              _reviewRow(
                Icons.straighten,
                'Size',
                '${sizeController.text} $sizeType',
              ),
              _reviewRow(
                Icons.currency_rupee,
                'Budget',
                '₹${budgetController.text}',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _paymentSummaryCard(),
      ],
    );
  }

  Widget _paymentSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xfff4f8fb),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xffc9d9ff)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Summary',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _paymentRow('Property Purpose', purpose),
          _paymentRow('Budget Range', '₹${_formatAmount(budget)}'),
          _paymentRow('Service Charge (20%)', '₹${_formatAmount(amount)}'),
          const Divider(height: 22),
          _paymentRow(
            'Total Amount',
            '₹${_formatAmount(amount)}',
            isTotal: true,
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xffe8efff),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Refund Policy: ',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(
                    text:
                        'If we cannot find a suitable property within 3 months, we will refund 15% and retain 5% as platform fee.',
                  ),
                ],
              ),
              style: TextStyle(
                color: Color(0xff3048ba),
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(int value) {
    final digits = value.toString();
    return digits.replaceAllMapped(
      RegExp(r'(?<=\d)(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
  }

  Widget _reviewRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          SizedBox(
            width: 105,
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, color: AppColors.gray500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffe2e7e4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _summaryRow('Purpose', purpose),
          _summaryRow(
            'Location',
            '$city, $state\n$area, ${pincodeController.text}',
          ),
          _summaryRow('Property type', propertyType),
          _summaryRow('Furnishing', furnishing),
          _summaryRow('Configuration', format),
          _summaryRow('Size', '${sizeController.text} $sizeType'),
          _summaryRow('Budget', '₹${budgetController.text}'),
          _summaryRow('Service charge (20%)', '₹$amount'),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: AppColors.gray500, fontSize: 13),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _heading(String title, String subtitle) => Column(
    children: [
      Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 25,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        subtitle,
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.gray500, fontSize: 14),
      ),
    ],
  );

  Widget _sectionLabel(String label) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 8),
    child: Text(
      label,
      style: const TextStyle(
        color: AppColors.primary,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    ),
  );

  Widget _chips(
    List<String> values,
    String selected,
    ValueChanged<String> onSelected,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          values.map((value) {
            final isSelected = selected == value;
            return ChoiceChip(
              label: Text(value),
              selected: isSelected,
              onSelected: (_) => onSelected(value),
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.primary,
              ),
              backgroundColor: Colors.white,
              side: const BorderSide(color: Color(0xffdce3df)),
            );
          }).toList(),
    );
  }

  Widget _field(
    String label,
    String value,
    List<String> values,
    ValueChanged<String?> onChanged,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: DropdownButtonFormField<String>(
      initialValue: value.isEmpty ? null : value,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xffe2e7e4)),
        ),
      ),
      items:
          [if (value.isNotEmpty && !values.contains(value)) value, ...values]
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
      onChanged: onChanged,
    ),
  );

  Widget _input(
    String label,
    TextEditingController controller,
    TextInputType keyboardType,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xffe2e7e4)),
        ),
      ),
    ),
  );

  Future<void> _showPaymentSummary() async {
    final shouldSubmit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Payment Summary'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _paymentRow('Property Purpose', purpose),
              _paymentRow('Budget Range', '₹$budget'),
              _paymentRow('Service Charge (20%)', '₹$amount'),
              const Divider(height: 24),
              _paymentRow('Total Amount', '₹$amount', isTotal: true),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xffeef4ff),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xffc4d8ff)),
                ),
                child: const Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Refund Policy: ',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      TextSpan(
                        text:
                            'If we cannot find a suitable property within 3 months, we will refund 15% and retain 5% as platform fee.',
                      ),
                    ],
                  ),
                  style: TextStyle(color: Color(0xff3048ba), fontSize: 13),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Back'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Pay & Submit'),
            ),
          ],
        );
      },
    );
    if (shouldSubmit == true && mounted) await _submitRequirement();
  }

  Widget _paymentRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: isTotal ? 16 : 14,
                fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 17 : 14,
              fontWeight: FontWeight.w700,
              color: isTotal ? AppColors.primary : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _footerActions() {
    if (isReviewing) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => setState(() => isReviewing = false),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Edit'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : _showPaymentSummary,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text(
                  'Submit Requirement',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final isLast = step == 3;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
      child: Row(
        children: [
          if (step > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => step--),
                child: const Text('Previous'),
              ),
            ),
          if (step > 0) const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed:
                  isSubmitting
                      ? null
                      : () {
                        if (isLast) {
                          setState(() => isReviewing = true);
                        } else {
                          setState(() => step++);
                        }
                      },
              icon: Icon(isLast ? Icons.payment : Icons.arrow_forward),
              label: Text(isLast ? 'Review & Pay' : 'Next'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
