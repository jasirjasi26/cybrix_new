// @dart=2.9
import 'package:cybrix/data/user_data.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GetVouchers{

  Future<void> getVouchers() async {

    final prefs = await SharedPreferences.getInstance();

    if (await DataConnectionChecker().hasConnection) {
      await FirebaseDatabase.instance
          .reference()
          .child("Companies")
          .child(User.database)
          .child("Vouchers")
          .child(User.vanNo)
          .once()
          .then((DataSnapshot snapshot) {
        Map<dynamic, dynamic> values = snapshot.value;
        values.forEach((key, values) {
            if (key.toString() == "ReturnNumber") {
              User().updateReturn(int.parse(values.toString()));
            }
            if (key.toString() == "VoucherNumber") {
              User().updateVoucherNumber(int.parse(values.toString()));
            }
            if (key.toString() == "OrderNumber") {
              User().updateOrder(int.parse(values.toString()));
            }
            if (key.toString() == "CashReceiptVoucher") {
              User().updateCashReceipt(int.parse(values.toString()));
            }
        });
      });
      int v=prefs.getInt("vouchernumber");
      int o=prefs.getInt("ordernumber");
      int r=prefs.getInt("returnnumber");
      int c=prefs.getInt("cashnumber");

      User.voucherNumber = User.voucherStarting+(v + 1).toString();
      User.orderNumber = User.orderStarting+(o + 1).toString();
      User.returnNumber = User.returnStarting+(r + 1).toString();
      User.cashReceiptNumber = User.cashReceiptStarting+(c + 1).toString();
    }else{
      int v=prefs.getInt("vouchernumber");
      int o=prefs.getInt("ordernumber");
      int r=prefs.getInt("returnnumber");
      int c=prefs.getInt("cashnumber");

      User.voucherNumber = User.voucherStarting+(v + 1).toString();
      User.orderNumber = User.orderStarting+(o + 1).toString();
      User.returnNumber = User.returnStarting+(r + 1).toString();
      User.cashReceiptNumber = User.cashReceiptStarting+(c + 1).toString();
    }

  }


}