import 'package:flutter/material.dart';

import 'package:flutter_nobrokeragefortenants/core/constants/app_colors.dart';
import 'package:flutter_nobrokeragefortenants/services/api/auth_api.dart';

class BrokerLeadsScreen extends StatefulWidget {
  const BrokerLeadsScreen({super.key});

  @override
  State<BrokerLeadsScreen> createState() => _BrokerLeadsScreenState();
}

class _BrokerLeadsScreenState extends State<BrokerLeadsScreen> {
  List<Map<String, dynamic>> leads = [];
  String selectedStatus = 'All';
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadLeads();
  }

  Future<void> _loadLeads() async {
    try {
      final response = await Authapi.brokerLeads(context: context, type: 'all');

      // Handle both Map and Response-like objects safely.
      dynamic payload;
      if (response is Map<String, dynamic>) {
        payload = response['data'] ?? response;
      } else {
        try {
          payload = (response as dynamic)['data'];
        } catch (_) {
          payload = response;
        }
      }

      final value =
          payload is Map<String, dynamic>
              ? payload['allLeads']
              : (payload is List ? payload : null);

      if (value is List) {
        leads = value.whereType<Map>().map(Map<String, dynamic>.from).toList();
      }
    } catch (_) {
      leads = [];
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  // ---------------------------------------------------------------- HELPERS

  String _value(Map<String, dynamic> lead, List<String> keys, String fallback) {
    for (final key in keys) {
      final value = lead[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }
    return fallback;
  }

  Map<String, dynamic> _nested(Map<String, dynamic> lead, List<String> keys) {
    for (final key in keys) {
      if (lead[key] is Map) return Map<String, dynamic>.from(lead[key]);
    }
    return lead;
  }

  List<Map<String, dynamic>> get filteredLeads {
    if (selectedStatus == 'All') return leads;
    return leads.where((lead) {
      final status = _value(lead, ['status'], '').toLowerCase();
      return status == selectedStatus.toLowerCase();
    }).toList();
  }

  String _getPhone(Map<String, dynamic> lead) {
    final customer = _nested(lead, ['customer', 'customerDetail', 'user']);
    return _value(customer, [
      'mobile',
      'mobileNumber',
      'phone',
      'phoneNumber',
      'contact',
    ], _value(lead, ['mobile', 'mobileNumber', 'phone', 'phoneNumber'], ''));
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  Color _statusBg(String status) {
    switch (status.toLowerCase()) {
      case 'new':
        return const Color(0xFFFFF3E0);
      case 'contacted':
        return const Color(0xFFE3F2FD);
      case 'converted':
        return const Color(0xFFE7F1EF);
      case 'rejected':
        return const Color(0xFFFFEBEE);
      default:
        return const Color(0xFFF1F3F5);
    }
  }

  Color _statusFg(String status) {
    switch (status.toLowerCase()) {
      case 'new':
        return const Color(0xFFC68A2E);
      case 'contacted':
        return const Color(0xFF1976D2);
      case 'converted':
        return const Color(0xFF2E9E5B);
      case 'rejected':
        return const Color(0xFFD9534F);
      default:
        return AppColors.gray500;
    }
  }

  // --------------------------------------------------------------- CALLING

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _callNumber(String phone) async {
    final cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleaned.isEmpty) {
      _showSnack('Invalid phone number');
      return;
    }

    final uri = Uri(scheme: 'tel', path: cleaned);

    try {} catch (_) {
      _showSnack('Could not open dialer');
    }
  }

  // ------------------------------------------------------------- BOOK VISIT

  void _bookVisit(Map<String, dynamic> lead) {
    final customer = _nested(lead, ['customer', 'customerDetail', 'user']);
    final name = _value(customer, ['fullName', 'name'], 'Customer');
    final property = _nested(lead, ['property', 'propertyDetail']);
    final propertyName = _value(property, [
      'title',
      'propertyName',
    ], 'this property');

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (_) =>
              _bookVisitSheet(customerName: name, propertyName: propertyName),
    );
  }

  // ------------------------------------------------------------------- BUILD

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            if (!loading && leads.isNotEmpty) _statusTabs(),
            Expanded(child: _body()),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------- HEADER

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.people_alt_rounded,
              color: AppColors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Broker Leads',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.blackColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  loading
                      ? 'Loading...'
                      : '${leads.length} ${leads.length == 1 ? "lead" : "leads"}',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.gray500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------- STATUS TABS

  Widget _statusTabs() {
    final statuses = ['All', 'New', 'Contacted', 'Converted'];
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: statuses.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final status = statuses[index];
          final selected = selectedStatus == status;
          final count =
              status == 'All'
                  ? leads.length
                  : leads
                      .where(
                        (lead) =>
                            _value(lead, ['status'], '').toLowerCase() ==
                            status.toLowerCase(),
                      )
                      .length;
          return _statusChip(
            label: status,
            count: count,
            selected: selected,
            onTap: () => setState(() => selectedStatus = status),
          );
        },
      ),
    );
  }

  Widget _statusChip({
    required String label,
    required int count,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? AppColors.primary : const Color(0xFFE6EAEA),
          ),
          boxShadow:
              selected
                  ? const [
                    BoxShadow(
                      color: Color(0x1A1F4F4A),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ]
                  : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                color: selected ? Colors.white : AppColors.gray500,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color:
                    selected
                        ? Colors.white.withOpacity(0.22)
                        : const Color(0xFFF1F3F5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------------- BODY

  Widget _body() {
    if (loading) {
      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: 5,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, __) => _shimmerCard(),
      );
    }

    if (leads.isEmpty) {
      return _emptyState();
    }

    final list = filteredLeads;

    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.inbox_outlined,
              size: 60,
              color: AppColors.gray500,
            ),
            const SizedBox(height: 10),
            Text(
              'No $selectedStatus leads',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.gray500,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadLeads,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        itemCount: list.length,
        itemBuilder: (context, index) => _leadCard(list[index], index),
      ),
    );
  }

  Widget _shimmerCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDF0F1),
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 13,
                      width: 140,
                      color: const Color(0xFFEDF0F1),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 11,
                      width: 100,
                      color: const Color(0xFFEDF0F1),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(height: 10, width: 180, color: const Color(0xFFEDF0F1)),
          const SizedBox(height: 8),
          Container(height: 10, width: 140, color: const Color(0xFFEDF0F1)),
          const SizedBox(height: 16),
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFEDF0F1),
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFE7F1EF),
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(
                Icons.people_outline_rounded,
                size: 56,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No leads yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.blackColor,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'New customer enquiries will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.gray500, fontSize: 12.5),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------- LEAD CARD

  Widget _leadCard(Map<String, dynamic> lead, int index) {
    final customer = _nested(lead, ['customer', 'customerDetail', 'user']);
    final property = _nested(lead, ['property', 'propertyDetail']);

    final customerName = _value(customer, ['fullName', 'name'], 'Customer');
    final phone = _getPhone(lead);
    final propertyName = _value(property, [
      'title',
      'propertyName',
    ], 'your property');
    final location = _value(property, ['location', 'area'], '-');
    final status = _value(lead, ['status'], 'New');
    final dateRaw = _value(lead, ['createdAt', 'date'], '');
    final date = _formatDate(dateRaw);

    final avatarColors = [
      const Color(0xFFEEE7FB),
      const Color(0xFFE8F3EA),
      const Color(0xFFE7EFFB),
      const Color(0xFFFFF3E0),
    ];
    final avatarColor = avatarColors[index % avatarColors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEFF2F2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: avatarColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                alignment: Alignment.center,
                child: Text(
                  _getInitials(customerName),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            customerName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.blackColor,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _statusBg(status),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              color: _statusFg(status),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(
                          Icons.phone_outlined,
                          size: 13,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            phone.isEmpty ? 'Mobile not available' : phone,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color:
                                  phone.isEmpty
                                      ? AppColors.gray500
                                      : AppColors.blackColor,
                            ),
                          ),
                        ),
                        if (phone.isNotEmpty)
                          GestureDetector(
                            onTap: () => _callNumber(phone),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE7F1EF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Call',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (date.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: 12,
                            color: AppColors.gray500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            date,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.gray500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFEFF2F2)),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 32,
                width: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFE7F1EF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.apartment_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      propertyName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.blackColor,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 12,
                          color: AppColors.gray500,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.gray500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton(
              onPressed: () => _bookVisit(lead),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_available_rounded, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Book Visit',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------- BOOK VISIT SHEET

  Widget _bookVisitSheet({
    required String customerName,
    required String propertyName,
  }) {
    final dateController = TextEditingController();
    final timeController = TextEditingController();
    DateTime? pickedDate;
    TimeOfDay? pickedTime;

    return StatefulBuilder(
      builder: (context, setSheetState) {
        return SafeArea(
          top: false,
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    height: 4,
                    width: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E4E4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Container(
                      height: 36,
                      width: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE7F1EF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.event_available_rounded,
                        color: AppColors.primary,
                        size: 19,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Book a Visit',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.blackColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F8FA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _summaryRow('Customer', customerName),
                      const SizedBox(height: 6),
                      _summaryRow('Property', propertyName),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Preferred Date',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.blackColor,
                  ),
                ),
                const SizedBox(height: 8),
                _pickerField(
                  hint: 'Select date',
                  value: dateController.text,
                  icon: Icons.calendar_today_outlined,
                  onTap: () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: pickedDate ?? now,
                      firstDate: now,
                      lastDate: now.add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setSheetState(() {
                        pickedDate = picked;
                        dateController.text =
                            '${picked.day.toString().padLeft(2, '0')}/'
                            '${picked.month.toString().padLeft(2, '0')}/'
                            '${picked.year}';
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Preferred Time',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.blackColor,
                  ),
                ),
                const SizedBox(height: 8),
                _pickerField(
                  hint: 'Select time',
                  value: timeController.text,
                  icon: Icons.access_time_rounded,
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime:
                          pickedTime ?? const TimeOfDay(hour: 10, minute: 0),
                    );
                    if (picked != null) {
                      setSheetState(() {
                        pickedTime = picked;
                        final period =
                            picked.period == DayPeriod.am ? 'AM' : 'PM';
                        final h =
                            picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
                        timeController.text =
                            '${h.toString().padLeft(2, '0')}:'
                            '${picked.minute.toString().padLeft(2, '0')} $period';
                      });
                    }
                  },
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Call your book-visit API here.
                      Navigator.pop(context);
                      _showSnack(
                        'Visit booked for $customerName on '
                        '${dateController.text} at ${timeController.text}',
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_rounded, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Confirm Visit',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 78,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              color: AppColors.gray500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.blackColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _pickerField({
    required String hint,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F8FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE6EAEA)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                value.isEmpty ? hint : value,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color:
                      value.isEmpty ? AppColors.gray500 : AppColors.blackColor,
                ),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.gray500,
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------------ DATE

  String _formatDate(String raw) {
    if (raw.trim().isEmpty) return '';
    try {
      final dt = DateTime.parse(raw).toLocal();
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      final h =
          dt.hour == 0
              ? 12
              : dt.hour > 12
              ? dt.hour - 12
              : dt.hour;
      final period = dt.hour >= 12 ? 'PM' : 'AM';
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}, '
          '${h.toString().padLeft(2, '0')}:'
          '${dt.minute.toString().padLeft(2, '0')} $period';
    } catch (_) {
      return raw;
    }
  }
}
