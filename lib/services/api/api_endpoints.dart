class AppEndpoints {
  /// base url
  static String baseUrl = 'https://nobrokeragefortenants.com/api/';
  static String imgUrl = "https://nobrokeragefortenants.com/";
  // static String baseUrl = 'http://192.168.1.11:2025/api/';
  // static String imgUrl = "http://192.168.1.11:2025/";

  /// use for login
  static String login = 'users/Login';
  static String areaurl = 'area/getlist';
  static String register = "users/register";
  static String brokerOptions = "users/broker-options";
  static String otpverify = "users/verify-otp";
  static String editprofile = "users/edituser";
  static String addproperty = "property/addproperty";
  static String dashboardapi = "property/brokerdashboard";
  static String brokerLeads = "interest/broker/leads";
  static String markInterest = "interest/mark";
  static String getproperties = "property/getbybrokerid";
  static String sharedProperties = "shareproperty/getproperties";
  static String mySharedProperties = "shareproperty/mine";
  static String updateproperty = "property/updateproperty";
  static String customerdetail = "shareproperty/getcustomer";
  static String changestatus = "shareproperty/changestatus";
  static String userVisits = "visit/myvisits";
  static String brokerVisits = "visit/broker/myvisits";
  static String confirmVisit(String visitId) => "visit/confirm/$visitId";
  static String cancelVisit(String visitId) => "visit/cancel/$visitId";
  static String userNotifications = "notification/user";
  static String brokerNotifications = "notification/broker";
  static String mySubscription = "subscription/mysubscription";
  static String requirementForm = "property/requirementForm";
  static String getRequirementForm = "property/getrequirementform";
  static String updateRequirement = "property/updateRequirement";
  static String createPaymentOrder = "payments/initiate";
  static String verifyPayment = "payments/verify";
  static String myproperties = "interest/app/myproperties";
  static const String razorpayKeyId = String.fromEnvironment(
    'RAZORPAY_KEY_ID',
    defaultValue: 'rzp_live_bmghTU3JLdsiP9',
  );
}
