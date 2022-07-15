import 'package:shared_preferences/shared_preferences.dart';

class User {
  static String name = "";
  static String vanNo = "";
  static String number = "";
  static String database = "";
  static String address = "";
  static String trno = "";
  static String companyName = "";
  static int decimals=0;

  static String voucherStarting = "V" + vanNo + "S";
  static String orderStarting = "V" + vanNo + "O";
  static String returnStarting = "V" + vanNo + "R";
  static String cashReceiptStarting = "V" + vanNo + "C";
  static String voucherNumber = "";
  static String orderNumber = "";
  static String returnNumber = "";
  static String cashReceiptNumber = "";

  updateVoucherNumber(int number) async {
    final prefs = await SharedPreferences.getInstance();
     prefs.setInt("vouchernumber",number);
  }
  updateOrder(int number) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt("ordernumber",number);
  }
  updateReturn(int number) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt("returnnumber",number);
  }
  updateCashReceipt(int number) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt("cashnumber",number);
  }

  addUser() async {
    // Obtain shared preferences.
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("name", name);
    prefs.setString("number", number);
    prefs.setString("vanNo", vanNo);
    prefs.setString("database", database);
    prefs.setString("address", address);
    prefs.setString("trno", trno);
    prefs.setString("companyName", companyName);
    prefs.setInt("decimal", decimals);
  }

  clear() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }
}
