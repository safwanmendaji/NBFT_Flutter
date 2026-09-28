import 'dart:developer';

import 'package:flutter/material.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/app_constants.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/app_colors.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/font_size.dart';
 import 'package:flutter_nobrokeragefortenants/widgets/customize_text_widget.dart';

 import 'package:flutter_nobrokeragefortenants/services/api/property_api.dart';
 import 'package:flutter_nobrokeragefortenants/services/network/error_manager.dart';

class MyCustomerCardCell extends StatefulWidget {
  final String customername;
  final String customeremail;
  final String customercontact;
  final String pricerange;
  final String propertyId;
  String? status;
  final int? index;
  MyCustomerCardCell(
      {super.key,
      this.index,
      required this.propertyId,
      required this.customername,
      required this.customeremail,
      required this.customercontact,
      required this.pricerange,
      required this.status});

  @override
  State<MyCustomerCardCell> createState() => _MyCustomerCardCellState();
}

class _MyCustomerCardCellState extends State<MyCustomerCardCell> {
  _updateStatusApi(String newstatus) async {
    await Propertyapis.changestatus(
      data: {"status": newstatus},
      context: context,
      propertyid: widget.propertyId,
    ).then((response) {
      if (response.statusCode == 201 || response.statusCode == 200) {
        log("APi Success");
        // customerdetail = response.data!.data ?? [];
        widget.status = newstatus;

        setState(() {});
      } else {
        log("Api failed");
      }
    }).catchError((error) {
      ErrorManager().showErrorDialogue(e: error, context: context);
    }).onError((error, stacktrace) {
      ErrorManager().showErrorDialogue(e: error, context: context);
    });
  }

  @override
  Widget build(BuildContext context) {
    getScreenSize(context);
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
              blurRadius: 5.6,
              color: const Color.fromARGB(
                25,
                0,
                0,
                0,
              ).withValues(alpha: 0.25))
        ],
        borderRadius: BorderRadius.circular(25),
        color: AppColors.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 14.0),
                child: getTextWidget(
                  title: widget.index!.toString(),
                  textFontWeight: AppFonts.medium,
                  textColor: AppColors.lightgreycolor,
                ),
              ),
              const SizedBox(
                width: 13.0,
              ),
              Container(
                width: 1,
                height: 150,
                color: const Color(0xffEAEAEA),
              ),
              const SizedBox(
                width: 2.0,
              ),
              Expanded(
                  child: Column(
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: screenSize!.width / 2.5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 5.0),
                              child: getTextWidget(
                                  title: widget.customername,
                                  maxLines: 1,
                                  textFontWeight: AppFonts.bold,
                                  textColor: AppColors.darkblack),
                            ),
                            const SizedBox(
                              height: 2.0,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 4.0),
                              child: getTextWidget(
                                  title: widget.customeremail,
                                  maxLines: 1,
                                  textFontWeight: AppFonts.medium,
                                  textColor: AppColors.profilecolor),
                            )
                          ],
                        ),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(right: 19.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            getTextWidget(
                                title: 'Contact Number',
                                textFontSize: AppFonts.size13,
                                textFontWeight: AppFonts.bold,
                                textColor: AppColors.contactus),
                            const SizedBox(
                              height: 2.0,
                            ),
                            getTextWidget(
                                title: widget.customercontact,
                                textFontSize: AppFonts.size12,
                                textFontWeight: AppFonts.medium,
                                textColor: AppColors.gray500)
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 9.0,
                  ),
                  Container(
                    width: screenSize!.width,
                    decoration: BoxDecoration(
                        border: Border.all(
                            width: 1, color: const Color(0xffDDDDDD))),
                  ),
                  const SizedBox(
                    height: 9.0,
                  ),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: getTextWidget(
                                title: 'Price Range',
                                textFontWeight: AppFonts.bold,
                                textColor: AppColors.darkblack),
                          ),
                          const SizedBox(
                            height: 2.0,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 3.0),
                            child: getTextWidget(
                                title: widget.pricerange,
                                textFontWeight: AppFonts.medium,
                                textColor: AppColors.profilecolor),
                          )
                        ],
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(right: 19.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            getTextWidget(
                                title: 'Status',
                                textFontSize: AppFonts.size13,
                                textFontWeight: AppFonts.bold,
                                textColor: AppColors.contactus),
                            const SizedBox(
                              height: 2.0,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: widget.status == "Connected"
                                    ? AppColors.lightgreen
                                    : widget.status == "Intersted"
                                        ? const Color.fromARGB(
                                            255, 247, 253, 191)
                                        : AppColors.lightindigo,
                                borderRadius: BorderRadius.circular(26),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 1.0, horizontal: 8.0),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: widget.status,
                                  items: [
                                    "Pending",
                                    "Interested",
                                    'Not-Interested',
                                  ].map((String newstatus) {
                                    return DropdownMenuItem<String>(
                                      value: newstatus,
                                      child: getTextWidget(
                                        title: newstatus,
                                        textFontSize: AppFonts.size12,
                                        textFontWeight: AppFonts.medium,
                                        textColor: newstatus == "Connected"
                                            ? AppColors.primary
                                            : newstatus == "Intersted"
                                                ? Colors.yellow
                                                : AppColors.inidgo,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (newValue) {
                                    if (newValue != null) {
                                      _updateStatusApi(newValue);
                                      setState(() {});
                                    }
                                  },
                                  dropdownColor: Colors.white,
                                  icon: const Icon(Icons.arrow_drop_down),
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ))
            ],
          ),
        ],
      ),
    );
  }
}
