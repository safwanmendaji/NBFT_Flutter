import 'package:flutter/material.dart';
import 'package:flutter_nobrokeragefortenants/models/subscription/my_subscription_model.dart';
import 'package:flutter_nobrokeragefortenants/services/api/property_api.dart';

class SubscriptionDetailsScreen extends StatefulWidget {
  const SubscriptionDetailsScreen({
    super.key,
  });

  @override
  State<SubscriptionDetailsScreen> createState() => _SubscriptionDetailsScreenState();
}

class _SubscriptionDetailsScreenState extends State<SubscriptionDetailsScreen> {
  MySubscriptionModel? subscriptionData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSubscription();
  }

  Future<void> _fetchSubscription() async {
    try {
      final response = await Propertyapis.getMySubscription(context: context);
      if (mounted) {
          subscriptionData = response;
          isLoading = false;
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
    finally{
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // COLORS
  // ============================================================

  static const Color background = Color(0xffF7F6F0);
  static const Color primary = Color(0xff11595B);
  static const Color darkText = Color(0xff1F3031);
  static const Color textColor = Color(0xff536264);
  static const Color muted = Color(0xff8B9697);
  static const Color border = Color(0xffE3E1D9);

  // ============================================================
  // HELPERS
  // ============================================================

  String _formatDate(String? dateString) {
    if (dateString == null) return '—';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day} ${_getMonthName(date.month)} ${date.year}';
    } catch (e) {
      return '—';
    }
  }

  int _getRemainingDays(String? endDate) {
    if (endDate == null) return 0;

    try {
      final expiryDate = DateTime.parse(endDate);

      final now = DateTime.now();

      final today = DateTime(
        now.year,
        now.month,
        now.day,
      );

      final expiry = DateTime(
        expiryDate.year,
        expiryDate.month,
        expiryDate.day,
      );

      final difference = expiry.difference(today).inDays;

      return difference > 0 ? difference : 0;
    } catch (e) {
      return 0;
    }
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  int _getDaysRemaining() {
    if (subscriptionData?.data?.endDate == null) return 0;
    try {
      final endDate = DateTime.parse(subscriptionData!.data!.endDate!);
      final now = DateTime.now();
      final difference = endDate.difference(now);
      return difference.isNegative ? 0 : difference.inDays;
    } catch (e) {
      return 0;
    }
  }

  double _getProgressValue() {
    if (subscriptionData?.data?.totalDays == null) return 0;
    final totalDays = subscriptionData!.data!.totalDays!;
    final daysRemaining = _getDaysRemaining();
    final daysElapsed = totalDays - daysRemaining;
    return totalDays > 0 ? (daysElapsed / totalDays).clamp(0.0, 1.0) : 0;
  }

  bool _isActive() {
    if (subscriptionData?.data?.isRefunded == true) return false;
    return _getDaysRemaining() > 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text("Manage Subscription",style: TextStyle(
          color: textColor,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          height: 1.35,
        ),),
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : subscriptionData?.data == null
                ? const Center(child: Text('No subscription data found'))
                : LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth >= 1100) {
                        return _desktopLayout(context);
                      }

                      if (constraints.maxWidth >= 700) {
                        return _tabletLayout(context);
                      }

                      return _mobileLayout(context);
                    },
                  ),
      ),
    );
  }

  // ============================================================
  // DESKTOP
  // ============================================================

  Widget _desktopLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        30,
        24,
        30,
        30,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1400,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              _pageHeader(),

              const SizedBox(height: 24),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ==================================================
                  // LEFT
                  // ==================================================

                  Expanded(
                    flex: 7,
                    child: Column(
                      children: [
                        _subscriptionCard(),

                        const SizedBox(height: 22),

                        _validityCard(),

                        const SizedBox(height: 22),

                        _includedCard(),

                        const SizedBox(height: 22),

                        _importantNotesCard(),

                        const SizedBox(height: 22),

                        _upgradeCard(),
                      ],
                    ),
                  ),

                  const SizedBox(width: 22),

                  // ==================================================
                  // RIGHT
                  // ==================================================

                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        _summaryCard(),

                        const SizedBox(height: 22),

                        //_refundCard(),

                        const SizedBox(height: 22),

                        _helpCard(),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              _bottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // TABLET
  // ============================================================

  Widget _tabletLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          _pageHeader(),

          const SizedBox(height: 20),

          _subscriptionCard(),

          const SizedBox(height: 18),

          _validityCard(),

          const SizedBox(height: 18),

          _includedCard(),

          const SizedBox(height: 18),

          _importantNotesCard(),

          const SizedBox(height: 18),

          _summaryCard(),

          const SizedBox(height: 18),

          //_refundCard(),

          const SizedBox(height: 18),

          _helpCard(),

          const SizedBox(height: 18),

          _upgradeCard(),

          const SizedBox(height: 18),

          _bottomBar(),
        ],
      ),
    );
  }

  // ============================================================
  // MOBILE
  // ============================================================

  Widget _mobileLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        16,
        18,
        16,
        24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          _pageHeader(),

          const SizedBox(height: 18),

          _subscriptionCard(),

          const SizedBox(height: 16),

          _validityCard(),

          const SizedBox(height: 16),

          _includedCard(),

          const SizedBox(height: 16),

          _summaryCard(),

          const SizedBox(height: 16),

          //_refundCard(),

          const SizedBox(height: 16),

          _importantNotesCard(),

          const SizedBox(height: 16),

          _helpCard(),

          const SizedBox(height: 16),

          _upgradeCard(),

          const SizedBox(height: 16),

          _bottomBar(),
        ],
      ),
    );
  }

  // ============================================================
  // PAGE HEADER
  // ============================================================

  Widget _pageHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text(
          'Subscription Details',
          style: TextStyle(
            color: darkText,
            fontSize: 27,
            fontWeight: FontWeight.w800,
            letterSpacing: -.5,
          ),
        ),

        SizedBox(height: 5),

        Text(
          'Manage your subscription, view benefits and track validity.',
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SUBSCRIPTION CARD
  // ============================================================

  Widget _subscriptionCard() {
    return _card(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 650;

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _planInfo(),

                const SizedBox(height: 24),

                _subscriptionMeta(),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 6,
                child: _planInfo(),
              ),

              const SizedBox(width: 30),

              Expanded(
                flex: 5,
                child: _subscriptionMeta(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _planInfo() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            Container(
              width: 78,
              height: 78,
              decoration: const BoxDecoration(
                color: primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.workspace_premium_rounded,
                color: Colors.white,
                size: 38,
              ),
            ),

            const SizedBox(width: 18),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text(
                    'Standard Plan',
                    style: TextStyle(
                      color: darkText,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 7),
                  _statusBadge(
                    _isActive() ? 'Active' : 'Inactive',
                    _isActive() ? const Color(0xffDDF4E4) : const Color(0xffFEE2E2),
                    _isActive() ? const Color(0xff269653) : const Color(0xffDC2626),
                  ),
                ],
              ),
            ),
          ],
        ),
        const Text(
          'You get access to personalized property matching, '
              'expert assistance and complete support until you '
              'find your perfect property.',
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            height: 1.45,
          ),
        ),
      ],
    );
  }

  Widget _subscriptionMeta() {
    final data = subscriptionData?.data;
    return Wrap(
      spacing: 30,
      runSpacing: 18,
      children: [
        _metaItem(
          'Subscription ID',
          data?.id?.substring(0, 8).toUpperCase() ?? '—',
          copyIcon: true,
        ),
        _metaItem(
          'Status',
          _isActive() ? 'Active' : 'Inactive',
          valueColor: _isActive() ? const Color(0xff269653) : const Color(0xffDC2626),
        ),
        _metaItem(
          'Plan Type',
          'Subscription',
        ),
        _metaItem(
          'Subscribed On',
          _formatDate(data?.startDate),
        ),
      ],
    );
  }

  // ============================================================
  // VALIDITY
  // ============================================================

  Widget _validityCard() {
    final data = subscriptionData?.data;
    final daysRemaining = _getDaysRemaining();
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          _sectionTitle('Subscription Validity'),

          const SizedBox(height: 25),

          LayoutBuilder(
            builder: (context, constraints) {
              final columns =
              constraints.maxWidth < 600 ? 2 : 4;

              return GridView.count(
                crossAxisCount: columns,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 15,
                mainAxisSpacing: 22,
                childAspectRatio:
                columns == 2 ? 2.3 : 1.5,
                children: [

                  _statItem(
                    icon: Icons.calendar_month_rounded,
                    iconColor: primary,
                    iconBackground: const Color(0xffE6F2F1),
                    title: 'Start Date',
                    value: _formatDate(data?.startDate),
                  ),

                  _statItem(
                    icon: Icons.event_available_rounded,
                    iconColor: const Color(0xff3878BC),
                    iconBackground: const Color(0xffEAF2FB),
                    title: 'End Date',
                    value: _formatDate(data?.endDate),
                  ),

                  _statItem(
                    icon: Icons.access_time_rounded,
                    iconColor: const Color(0xff8061B8),
                    iconBackground: const Color(0xffF2EBFA),
                    title: 'Days Remaining',
                    value: '$daysRemaining Days',
                  ),

                  _statItem(
                    icon: Icons.hourglass_bottom_rounded,
                    iconColor: const Color(0xffAD8236),
                    iconBackground: const Color(0xffF7F0E4),
                    title: 'Total Duration',
                    value: '${data?.totalDays ?? 0} ${(data?.totalDays ?? 0) == 1 ? 'Day' : 'Days'}',
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 24),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              minHeight: 7,
              value: _getProgressValue(),
              backgroundColor: const Color(0xffEAE7DE),
              valueColor: const AlwaysStoppedAnimation(
                primary,
              ),
            ),
          ),

          const SizedBox(height: 11),

          Text(
            _isActive()
                ? 'Subscription is active and valid. You can continue exploring matched properties.'
                : 'Subscription has expired. Please renew to continue exploring matched properties.',
            style: const TextStyle(
              color: textColor,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INCLUDED
  // ============================================================

  Widget _includedCard() {
    final items = [
      (
      'Personalized\nProperty\nMatching',
      'Carefully selected properties that match your requirements.',
      ),
      (
      'Property Visits',
      'Schedule and visit properties with expert guidance.',
      ),
      (
      'Expert\nAssistance',
      'Dedicated property advisor throughout your journey.',
      ),
      (
      'Document\nSupport',
      'Help with documentation and verification.',
      ),
      (
      'Refund Policy',
      'Applicable refund if you don’t finalize within the validity.',
      ),
    ];

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          _sectionTitle("What's Included in Your Plan"),

          const SizedBox(height: 24),

          LayoutBuilder(
            builder: (context, constraints) {
              final count =
              constraints.maxWidth < 550
                  ? 1
                  : constraints.maxWidth < 850
                  ? 2
                  : 5;

              return GridView.builder(
                shrinkWrap: true,
                physics:
                const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: count,
                  crossAxisSpacing: 18,
                  mainAxisSpacing: 22,
                  childAspectRatio:
                  count == 1 ? 4.2 : 1.25,
                ),
                itemBuilder: (context, index) {
                  return _benefitItem(
                    items[index].$1,
                    items[index].$2,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _benefitItem(
      String title,
      String description,
      ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            color: Color(0xffDDF4E4),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            size: 13,
            color: Color(0xff299B55),
          ),
        ),

        const SizedBox(width: 9),

        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [

              Text(
                title,
                style: const TextStyle(
                  color: darkText,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 6),

              Expanded(
                child: Text(
                  description,
                  maxLines: 1,
                  style: const TextStyle(
                    color: textColor,
                    fontSize: 12,
                    height: 1.35,

                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  Widget _summaryCard() {
    final data = subscriptionData?.data;
    final requirement = data?.customerPropertyRequirement;
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          _sectionTitle('Subscription Summary'),

          const SizedBox(height: 20),

          _summaryRow(
            Icons.description_outlined,
            'Plan Name',
            'Subscription',
          ),

          _summaryRow(
            Icons.home_work_outlined,
            'Property Purpose',
            requirement?.propertyPurpose ?? '—',
          ),

          _summaryRow(
            Icons.home_outlined,
            'Property Type',
            requirement?.propertyType ?? '—',
          ),

          _summaryRow(
            Icons.square_foot_rounded,
            'Area',
            '${requirement?.area ?? '—'}, ${requirement?.city ?? '—'}',
          ),

          _summaryRow(
            Icons.payments_outlined,
            'Amount Paid',
            '₹${data?.amountPaid ?? 0}',
          ),

          _summaryRow(
            Icons.receipt_long_outlined,
            'Service Fee',
            'One-time Payment',
          ),

          _summaryRow(
            Icons.check_circle_outline,
            'Payment Status',
            'Paid',
            valueColor: const Color(0xff269653),
          ),

          _summaryRow(
            Icons.event_outlined,
            'Next Billing',
            _formatDate(data?.endDate),
          ),

          const SizedBox(height: 12),

          _outlineButton(
            icon: Icons.receipt_long_outlined,
            text: 'View Payment History',
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  // ============================================================
  // REFUND
  // ============================================================

  Widget _refundCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          _sectionTitle(
            'Refund Eligibility (Preview)',
          ),

          const SizedBox(height: 18),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xffE2F5E8),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [

                Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    color: Color(0xffCDEED8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified_user_outlined,
                    color: Color(0xff29864C),
                  ),
                ),

                const SizedBox(width: 12),

                const Expanded(
                  child: Text(
                    "You are currently eligible for refund "
                        "if you don't finalize within the validity period.",
                    style: TextStyle(
                      color: Color(0xff287A45),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          _outlineButton(
            text: 'Check Refund Eligibility',
            trailing: Icons.arrow_forward_rounded,
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  // ============================================================
  // IMPORTANT NOTES
  // ============================================================

  Widget _importantNotesCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: Color(0xff3878BC),
                size: 21,
              ),
              SizedBox(width: 10),
              Text(
                'Important Notes',
                style: TextStyle(
                  color: darkText,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          _bullet(
            'Your subscription is valid for 91 days from the start date.',
          ),

          _bullet(
            'If you do not finalize a property within the validity period, '
                'you may be eligible for a refund as per our policy.',
          ),

          _bullet(
            'For any assistance, contact your property advisor or our support team.',
          ),

          const SizedBox(height: 8),

          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              foregroundColor: primary,
            ),
            child: const Text(
              'View Refund Policy  →',
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 7,
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [

          const Text(
            '•',
            style: TextStyle(
              color: textColor,
              fontSize: 16,
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: textColor,
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HELP
  // ============================================================

  Widget _helpCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [

                    _sectionTitle('Need Help?'),

                    const SizedBox(height: 7),

                    const Text(
                      'Our support team is available from '
                          '9:00 AM to 9:00 PM.',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: Color(0xffE8F3F2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.headset_mic_outlined,
                  color: primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          _outlineButton(
            icon: Icons.headset_mic_outlined,
            text: 'Contact Support',
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  // ============================================================
  // UPGRADE
  // ============================================================

  Widget _upgradeCard() {
    return _card(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final mobile = constraints.maxWidth < 500;

          if (mobile) {
            return Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                _upgradeText(),

                const SizedBox(height: 15),

                _primaryButton(
                  text: 'Upgrade Plan',
                  onPressed: () {},
                ),
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                child: _upgradeText(),
              ),

              const SizedBox(width: 20),

              _primaryButton(
                text: 'Upgrade Plan',
                onPressed: () {},
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _upgradeText() {
    return const Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [

        Text(
          'Upgrade Your Experience',
          style: TextStyle(
            color: darkText,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),

        SizedBox(height: 5),

        Text(
          'Upgrade to Premium Plan for extended validity '
              'and additional benefits.',
          style: TextStyle(
            color: textColor,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // BOTTOM BAR
  // ============================================================

  Widget _bottomBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: border,
        ),
      ),
      child: const Wrap(
        alignment: WrapAlignment.spaceBetween,
        runSpacing: 10,
        spacing: 20,
        children: [

          Text(
            '🛡 100% Transparent Process  •  Verified Properties  •  No Brokerage',
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),

          Text(
            'Need help? Call us anytime  📞 +91 98765 43210',
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // COMMON CARD
  // ============================================================

  Widget _card({
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: .035,
            ),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: darkText,
        fontSize: 17,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  // ============================================================
  // META
  // ============================================================

  Widget _metaItem(
      String title,
      String value, {
        bool copyIcon = false,
        Color? valueColor,
      }) {
    return SizedBox(
      width: 125,
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [

          Text(
            title,
            style: const TextStyle(
              color: muted,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 4),

          Row(
            children: [

              Flexible(
                child: Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: valueColor ?? darkText,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              if (copyIcon) ...[
                const SizedBox(width: 5),
                const Icon(
                  Icons.copy_outlined,
                  size: 13,
                  color: muted,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STATUS
  // ============================================================

  Widget _statusBadge(
      String text,
      Color background,
      Color foreground,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: foreground,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ============================================================
  // STAT
  // ============================================================

  Widget _statItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBackground,
    required String title,
    required String value,
  }) {
    return Column(
      children: [

        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: iconBackground,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 23,
          ),
        ),

        const SizedBox(height: 9),

        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: muted,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),


        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: darkText,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SUMMARY ROW
  // ============================================================

  Widget _summaryRow(
      IconData icon,
      String title,
      String value, {
        Color? valueColor,
      }) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 15,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [

          Icon(
            icon,
            size: 17,
            color: muted,
          ),

          const SizedBox(width: 9),

          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: textColor,
                fontSize: 13,
              ),
            ),
          ),

          Flexible(
            child: Text(
              value.trim(),
              style: TextStyle(
                color: valueColor ?? darkText,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // OUTLINE BUTTON
  // ============================================================

  Widget _outlineButton({
    IconData? icon,
    required String text,
    IconData? trailing,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: darkText,
          side: const BorderSide(
            color: border,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
        ),
        child: Row(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [

            if (icon != null) ...[
              Icon(
                icon,
                size: 17,
              ),
              const SizedBox(width: 8),
            ],

            Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),

            if (trailing != null) ...[
              const SizedBox(width: 8),
              Icon(
                trailing,
                size: 17,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PRIMARY BUTTON
  // ============================================================

  Widget _primaryButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 46,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_rounded,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}