import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../models/properties/properties_model.dart';
import '../../services/api/property_api.dart';

class PropertyVisitBookingScreen extends StatefulWidget {
  const PropertyVisitBookingScreen({
    super.key,
     required this.property
  });
  final Data property;

  @override
  State<PropertyVisitBookingScreen> createState() =>
      _PropertyVisitBookingScreenState();
}

class _PropertyVisitBookingScreenState
    extends State<PropertyVisitBookingScreen> {

  // ------------------------------------------------------------
  // COLORS
  // ------------------------------------------------------------

  static const Color primary = Color(0xff244D4D);
  static const Color textColor = Color(0xff263536);
  static const Color mutedColor = Color(0xff8B9394);
  static const Color borderColor = Color(0xffE0E1DC);
  static const Color availableColor = Color(0xff63A76F);

  // ------------------------------------------------------------
  // CALENDAR
  // ------------------------------------------------------------

  late DateTime _firstDay;
  late DateTime _focusedDay;
  DateTime? _selectedDay;

  // ------------------------------------------------------------
  // TIME SLOT
  // ------------------------------------------------------------

  String? _selectedTime;

  final List<String> _timeSlots = [
  ];

  // ------------------------------------------------------------
  // DATE SELECTED
  // ------------------------------------------------------------

  void _onDateSelected(
      DateTime selectedDay,
      DateTime focusedDay,
      ) async {
    _timeSlots.clear();
    final response = await Propertyapis.getVisitAvailability(
      isShowProgress: true,
      propertyId: "6a6b183569e56532c900d3bf",
      //propertyId: widget.property.sId.toString(),
      date: '${selectedDay.year}-${selectedDay.month}-${selectedDay.day}',
      context: context,
    );
    response.data?.slots?.forEach((element) {
      _timeSlots.add(element.startTime??"");
    });
    setState(()  {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _selectedTime = null;
    });
    print("RESPOSNE ${response.data?.slots}");
  }



  // ------------------------------------------------------------
  // CONTINUE
  // ------------------------------------------------------------

  void _continueBooking() async{
    if (_selectedDay == null || _selectedTime == null) {
      return;
    }

    debugPrint(
      'Selected Date: $_selectedDay\n'
          'Selected Time: $_selectedTime',
    );

    final response = await Propertyapis.scheduleVisit(
      isShowProgress: true,
      endTime: _add45Minutes(_selectedTime!),
      startTime: _selectedTime!,
      //propertyId: widget.property.sId.toString(),
      propertyId:"6a6b183569e56532c900d3bf",
      visitDate: '${_selectedDay?.year}-${_selectedDay?.month}-${_selectedDay?.day}',
      context: context,
    );
    print("BOOK RESPONSE ${response.toJson()}");

    // Navigate to confirmation screen
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------


  @override
  void initState() {
    super.initState();

    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    _firstDay = today;
    _focusedDay = today;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F7F4),
      appBar: AppBar(
        backgroundColor: const Color(0xffF7F7F4),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Schedule Visit',
          style: TextStyle(
            color: textColor,
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            16,
            8,
            16,
            30,
          ),
          child: Column(
            children: [

              // ======================================================
              // STEP 1 - DATE
              // ======================================================

              _buildDateCard(),

              // ======================================================
              // STEP 2 - TIME
              // ======================================================

              AnimatedSize(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOut,
                child: _selectedDay == null
                    ? const SizedBox.shrink()
                    : Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: _buildTimeSlotCard(),
                ),
              ),

              // ======================================================
              // CONTINUE BUTTON
              // ======================================================

              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                child: _selectedTime == null
                    ? const SizedBox.shrink()
                    : Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: _buildContinueButton(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================================================================
  // DATE CARD
  // ================================================================

  Widget _buildDateCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        20,
        22,
        20,
        18,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: borderColor,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ----------------------------------------------------------
          // HEADER
          // ----------------------------------------------------------

          Row(
            children: [
              _stepNumber(1),

              const SizedBox(width: 12),

              const Text(
                'Select Visit Date',
                style: TextStyle(
                  color: textColor,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          // ----------------------------------------------------------
          // CALENDAR
          // ----------------------------------------------------------

          TableCalendar(
            firstDay: _firstDay,

            lastDay: DateTime(
              _firstDay.year + 1,
              12,
              31,
            ),

            focusedDay: _focusedDay,

            selectedDayPredicate: (day) {
              return isSameDay(
                _selectedDay,
                day,
              );
            },

            onDaySelected: _onDateSelected,

            headerVisible: true,

            // Your existing headerStyle...
          ),

          const SizedBox(height: 12),

          // ----------------------------------------------------------
          // LEGEND
          // ----------------------------------------------------------

          Wrap(
            spacing: 18,
            runSpacing: 8,
            children: [
              _legendItem(
                color: availableColor,
                text: 'Available',
              ),
              _legendItem(
                color: const Color(0xffC8C9C5),
                text: 'Unavailable',
              ),
              _legendItem(
                color: primary,
                text: 'Selected',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================================================================
  // TIME SLOT CARD
  // ================================================================

  Widget _buildTimeSlotCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        20,
        20,
        20,
        18,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: borderColor,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ----------------------------------------------------------
          // HEADER
          // ----------------------------------------------------------

          Row(
            children: [
              _stepNumber(2),

              const SizedBox(width: 12),

              const Text(
                'Select Time Slot',
                style: TextStyle(
                  color: textColor,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ----------------------------------------------------------
          // SELECTED DATE
          // ----------------------------------------------------------

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 11,
            ),
            decoration: BoxDecoration(
              color: const Color(0xffF1F6F4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_month_rounded,
                  size: 18,
                  color: primary,
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDate(_selectedDay!),
                  style: const TextStyle(
                    color: primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ----------------------------------------------------------
          // TIME SLOTS
          // ----------------------------------------------------------
        if(_timeSlots.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _timeSlots.length,
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 3.2,
            ),
            itemBuilder: (context, index) {
              final time = _timeSlots[index];

              final selected =
                  _selectedTime == time;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTime = time;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(
                    milliseconds: 200,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? primary
                        : Colors.white,
                    borderRadius:
                    BorderRadius.circular(14),
                    border: Border.all(
                      color: selected
                          ? primary
                          : borderColor,
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: [
                        if (selected) ...[
                          const Icon(
                            Icons.check_circle_rounded,
                            color: Colors.white,
                            size: 17,
                          ),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          time,
                          style: TextStyle(
                            color: selected
                                ? Colors.white
                                : textColor,
                            fontSize: 14,
                            fontWeight:
                            FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          )else
            const Center(child: Text("No Time Slots Available",
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),)),

          const SizedBox(height: 16),

          // ----------------------------------------------------------
          // INFO
          // ----------------------------------------------------------

          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 17,
                color: mutedColor,
              ),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'Visit duration is approximately 30–45 minutes.',
                  style: TextStyle(
                    color: mutedColor,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================================================================
  // CONTINUE BUTTON
  // ================================================================

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _continueBooking,
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Continue',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_rounded,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // STEP NUMBER
  // ================================================================

  Widget _stepNumber(int number) {
    return Container(
      width: 38,
      height: 38,
      decoration: const BoxDecoration(
        color: primary,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        '$number',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  // ================================================================
  // LEGEND
  // ================================================================

  Widget _legendItem({
    required Color color,
    required String text,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 15,
          height: 15,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: mutedColor,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ================================================================
  // FORMAT DATE
  // ================================================================

  String _formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _add45Minutes(String timeStr) {
    final parts = timeStr.split(' ');
    final timePart = parts[0];
    final period = parts[1];

    final timeParts = timePart.split(':');
    var hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    if (period == 'PM' && hour != 12) {
      hour += 12;
    } else if (period == 'AM' && hour == 12) {
      hour = 0;
    }

    final dateTime = DateTime(2024, 1, 1, hour, minute);
    final newDateTime = dateTime.add(const Duration(minutes: 45));

    var newHour = newDateTime.hour;
    final newMinute = newDateTime.minute;
    final newPeriod = newHour >= 12 ? 'PM' : 'AM';

    if (newHour > 12) {
      newHour -= 12;
    } else if (newHour == 0) {
      newHour = 12;
    }

    return '${newHour.toString().padLeft(2, '0')}:${newMinute.toString().padLeft(2, '0')} $newPeriod';
  }
}