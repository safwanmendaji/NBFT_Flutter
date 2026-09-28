import 'package:flutter/material.dart';

extension StringValidator on String {
  String? validateName(BuildContext context) {
    if (isEmpty) {
      return "name is required";
    }
    return null;
  }

  String? validateFullName(BuildContext context) {
    if (isEmpty) {
      return "Name is required";
    } else if (trim().length < 2) {
      return "Name must be 4 character long";
    }
    return null;
  }

  String? validateEmail(BuildContext context) {
    RegExp emailRegExp = RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");
    if (isEmpty) {
      return "Email is required";
    } else {
      if (!emailRegExp.hasMatch(this)) {
        return "Please enter a correct email";
      }
    }
    return null;
  }

  String? validatePassword(BuildContext context) {
    if (isEmpty) {
      return "Password is required";
    } else if (length < 8) {
      return "Password must be at least 8 characters long";
    } else if (!RegExp(r'[A-Z]').hasMatch(this)) {
      return "Password must contain at least one uppercase letter";
    } else if (!RegExp(r'[a-z]').hasMatch(this)) {
      return "Password must contain at least one lowercase letter";
    } else if (!RegExp(r'[0-9]').hasMatch(this)) {
      return "Password must contain at least one number";
    } else if (!RegExp(r'[!@#\$&*~_%-]').hasMatch(this)) {
      return "Password must contain at least one special character";
    }
    return null;
  }

  String? validateMobileNumber(BuildContext context) {
    if (isEmpty) {
      return "Mobile Number is required";
    } else if (length < 10) {
      return "Number must be 10 digit's";
    }
    return null;
  }

  String? validateRequireField(BuildContext context) {
    if (isEmpty) {
      return 'This feild is required';
    }
    return null;
  }

  // String? validateConfirmPassword(String conPass, BuildContext context) {
  //   if (isEmpty) {
  //     return AppLocalizations.of(context)!.confirmpasswordvalidation;
  //   } else if (conPass.trim() != trim()) {
  //     return AppLocalizations.of(context)!.confirmpasswordverifyvalidation;
  //   }
  //   return null;
  // }

//   String? validateWithMinimum(BuildContext context, int minimumValue) {
//     if (isEmpty) {
//       return AppLocalizations.of(context)!.reqirefieldvalidation;
//     } else if (length < minimumValue) {
//       return "${AppLocalizations.of(context)!.validcharacterlenghtstring} $minimumValue ${AppLocalizations.of(context)!.charactersstring}";
//     }
//     return null;
//   }
// }

// extension TitleCaseString on String {
//   String toTitleCase() {
//     return split(' ').map((word) {
//       if (word.isNotEmpty) {
//         return word[0].toUpperCase() + word.substring(1).toLowerCase();
//       } else {
//         return '';
//       }
//     }).join(' ');
//   }

  String toFirstCapitalCase() {
    if (isEmpty) return this;
    List<String> words = split(' ');
    if (words[0].isNotEmpty) {
      words[0] = words[0][0].toUpperCase() + words[0].substring(1);
    }
    return words.join(' ');
  }
}

extension TitleCaseList on List<String> {
  List<String> toTitleCase() {
    return map((word) =>
        word.substring(0, 1).toUpperCase() +
        word.substring(1).toLowerCase()).toList();
  }
}
