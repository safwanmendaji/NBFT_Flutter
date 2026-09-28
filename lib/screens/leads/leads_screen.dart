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
      final payload =
          response is Map<String, dynamic> ? response['data'] : null;
      final value =
          payload is Map<String, dynamic> ? payload['allLeads'] : null;
      if (value is List) {
        leads = value.whereType<Map>().map(Map<String, dynamic>.from).toList();
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  String _value(Map<String, dynamic> lead, List<String> keys, String fallback) {
    for (final key in keys) {
      final value = lead[key];
      if (value != null && value.toString().isNotEmpty) return value.toString();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body:
          loading
              ? const Center(child: CircularProgressIndicator())
              : leads.isEmpty
              ? const Center(child: Text('No recent leads'))
              : Column(
                children: [
                  SizedBox(
                    height: 56,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children:
                          [
                            'All',
                            'New',
                            'Contacted',
                            'Converted',
                          ].map((status) => _statusTab(status)).toList(),
                    ),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _loadLeads,
                      child: ListView.separated(
                        padding: const EdgeInsets.only(top: 4),
                        itemCount: filteredLeads.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder:
                            (context, index) =>
                                _leadRow(filteredLeads[index], index),
                      ),
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _statusTab(String status) {
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
    final selected = selectedStatus == status;
    return GestureDetector(
      onTap: () => setState(() => selectedStatus = status),
      child: Container(
        margin: const EdgeInsets.only(right: 28),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? AppColors.primary : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        padding: const EdgeInsets.only(top: 18),
        child: Text(
          '$status ($count)',
          style: TextStyle(
            color: selected ? AppColors.primary : AppColors.gray500,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _leadRow(Map<String, dynamic> lead, int index) {
    final customer = _nested(lead, ['customer', 'customerDetail', 'user']);
    final property = _nested(lead, ['property', 'propertyDetail']);
    final status = _value(lead, ['status'], 'New');
    final statusColor =
        status.toLowerCase() == 'new'
            ? const Color(0xfff7edcf)
            : const Color(0xffdff1e1);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor:
                [
                  const Color(0xffeee7fb),
                  const Color(0xffe8f3ea),
                  const Color(0xffe7effb),
                ][index % 3],
            child: const Icon(Icons.person_outline, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _value(customer, ['fullName', 'name'], 'Customer'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Interested in ${_value(property, ['title', 'propertyName'], 'your property')}',
                  style: const TextStyle(color: AppColors.gray500),
                ),
                const SizedBox(height: 6),
                Text(
                  _value(property, ['location', 'area'], '-'),
                  style: const TextStyle(color: AppColors.gray500),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Text(
            _value(lead, ['createdAt', 'date'], ''),
            style: const TextStyle(color: AppColors.gray500, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
