import 'dart:developer';

import 'package:flutter/material.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/app_colors.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/font_size.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/app_images.dart';
 import 'package:flutter_nobrokeragefortenants/core/utils/current_date.dart';
 import 'package:flutter_nobrokeragefortenants/models/customer/customer_model.dart';
 import 'package:flutter_nobrokeragefortenants/widgets/customer_card_cell.dart';
 import 'package:flutter_nobrokeragefortenants/widgets/custom_header_logo.dart';
 import 'package:flutter_nobrokeragefortenants/widgets/customize_text_form_field.dart';
 import 'package:flutter_nobrokeragefortenants/widgets/customize_text_widget.dart';
 import 'package:flutter_nobrokeragefortenants/widgets/header.dart';
import 'package:lottie/lottie.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/app_constants.dart';
 import 'package:flutter_nobrokeragefortenants/services/api/property_api.dart';
 import 'package:flutter_nobrokeragefortenants/services/network/error_manager.dart';

class MyCustomerDetails extends StatefulWidget {
  final String propertyId;
  const MyCustomerDetails({super.key, required this.propertyId});

  @override
  State<MyCustomerDetails> createState() => _MyCustomerDetailsState();
}

class _MyCustomerDetailsState extends State<MyCustomerDetails> {
  final _searchController = TextEditingController();
  List option = ["All", "Interested", "Not Interested", "Not Connected"];
  List<CustomerData> customerdetail = [];
  int isSelect = 0;

  _getCustomerApi({int? from}) async {
    var filterparams = {
      "search": _searchController.text.toString(),
      "page": "",
      "limit": "",
      "status": option[isSelect] ?? "",
    };

    await Propertyapis.getcustomerdetail(
          isShowProgress: from == 3 ? false : true,
          context: context,
          id: widget.propertyId,
          params:
              from == 0
                  ? {}
                  : from == 3
                  ? {"status": isSelect == 0 ? "" : option[isSelect]}
                  : filterparams,
        )
        .then((response) {
          if (response.statusCode == 201 || response.statusCode == 200) {
            log("APi Success");
            customerdetail = response.data!.data ?? [];

            setState(() {});
          } else {
            log("Api failed");
          }
        })
        .catchError((error) {
          ErrorManager().showErrorDialogue(e: error, context: context);
        })
        .onError((error, stacktrace) {
          ErrorManager().showErrorDialogue(e: error, context: context);
        });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Durations.medium1, () {
      _getCustomerApi(from: 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MyCustomHeaderLogo(),
          const MyCustomHeader(
            title: "Suggested Customers",
            isBackButton: true,
          ),

          // _getCurrentDay(),
          _getSearchbar(),
          _getOptions(),
          customerdetail.isEmpty
              ? Center(
                child: Column(
                  children: [
                    Lottie.asset(
                      'assets/animation/no_customer.json',
                      width: 200,
                      height: 200,
                      repeat: true,
                    ),
                    getTextWidget(
                      textAlign: TextAlign.center,
                      textColor: AppColors.white,
                      title: 'No Customer for this Property ',
                      textFontSize: AppFonts.size20,
                      textFontWeight: AppFonts.semiBold,
                    ),
                  ],
                ),
              )
              : Expanded(
                child: SingleChildScrollView(child: _getCustomerCard()),
              ),
        ],
      ),
    );
  }

  _getCustomerCard() => Padding(
    padding: const EdgeInsets.only(
      left: 15.0,
      right: 15.0,
      top: 15.0,
      bottom: 30.0,
    ),
    child: ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: customerdetail.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: MyCustomerCardCell(
            status: customerdetail[index].status!,
            index: index + 1,
            customeremail: customerdetail[index].sharedWith!.email!,
            customercontact: customerdetail[index].sharedWith!.mobileNo!,
            customername: customerdetail[index].sharedWith!.fullName!,
            pricerange:
                customerdetail[index].customerRequirements!.first.priceRange!,
            propertyId: customerdetail[index].sId!.toString(),
          ),
        );
      },
    ),
  );
  _getOptions() => Padding(
    padding: const EdgeInsets.only(top: 11.0, left: 16.0, right: 16.0),
    child: Container(
      width: screenSize!.width,
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: const Color(0XFFDFE0E2), width: 1.0),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          left: 8.0,
          top: 6.39,
          bottom: 6.39,
          right: 1.0,
        ),
        child: SizedBox(
          height: 38,
          child: ListView.builder(
            itemCount: option.length,
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  isSelect = index;
                  setState(() {});
                  _getCustomerApi(from: 3);
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color:
                          isSelect == index
                              ? AppColors.secondary
                              : const Color(0XFFF4F4F4),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: getTextWidget(
                        title: option[index],
                        textFontSize: AppFonts.size13,
                        textFontWeight: AppFonts.semiBold,
                        textColor:
                            isSelect == index
                                ? AppColors.white
                                : const Color(0xffA1A9B8),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    ),
  );

  _getSearchbar() => Padding(
    padding: const EdgeInsets.only(top: 15.0, left: 16.0, right: 17.0),
    child: Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          // BoxShadow(
          //   spreadRadius: 1,
          //   blurRadius: 0,
          //   offset: const Offset(0, 0),
          //   color: const Color(0XFF68718229).withValues(alpha: 16.0),
          // ),
          // const BoxShadow(
          //   spreadRadius: 0,
          //   blurRadius: 2,
          //   offset: Offset(0, 1),
          //   color: Color(0Xff0000000f),
          // ),
        ],
      ),
      child: PrimaryTextFeild(
        borderradius: 20,
        hintText: 'Search...',
        hintColor: const Color(0XFFA1A9B8),
        controller: _searchController,
        onfeildSubmitted: (value) {
          _getCustomerApi();
        },
        textInputAction: TextInputAction.search,
        prefixIcon: AppIcons.icSearch,
        prefixiconcolor: const Color(0XFFA1A9B8),
      ),
    ),
  );

  _getCurrentDay() => Padding(
    padding: const EdgeInsets.only(top: 1.0, left: 33.0),
    child: getTextWidget(
      title: getFormattedDate(),
      textFontSize: AppFonts.size16,
      textColor: AppColors.daycolor,
    ),
  );
}
