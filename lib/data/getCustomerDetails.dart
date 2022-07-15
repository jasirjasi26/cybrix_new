import 'dart:convert';

import 'package:api_cache_manager/models/cache_db_model.dart';
import 'package:api_cache_manager/utils/cache_manager.dart';
import 'package:cybrix/data/user_data.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:firebase_database/firebase_database.dart';

import 'customed_details.dart';

class GetCustomerDetails{
  Future<void> getCustomerId(String customerName) async {

    if (await DataConnectionChecker().hasConnection) {
      await FirebaseDatabase.instance
          .reference()
          .child("Companies")
          .child(User.database)
          .child("Customers").once().then((DataSnapshot snapshot) async {
        Map<dynamic, dynamic> values = snapshot.value;
        APICacheDBModel cacheDBModel =
        new APICacheDBModel(key: "customers", syncData: jsonEncode(values));

        await APICacheManager().addCacheData(cacheDBModel);
        var cacheData = await APICacheManager().getCacheData("customers");

        jsonDecode(cacheData.syncData).forEach((key, values) {
          if (customerName == values["Name"]) {

            Customer.CustomerId = values["CustomerID"];
            double a = double.parse(values["Balance"]);
            Customer.balance = a.toStringAsFixed(User.decimals);
            Customer.CustomerName = values["Name"].toString();

          } else {
            if (customerName == values["CustomerCode"]) {

              Customer.CustomerId = values["CustomerID"];
              double a = double.parse(values["Balance"]);
              Customer.balance = a.toStringAsFixed(User.decimals);
              Customer.CustomerName = values["Name"].toString();
            }
          }
        });

      });
    }
    else{
      var cacheData = await APICacheManager().getCacheData("customers");

      jsonDecode(cacheData.syncData).forEach((key, values) {
        if (customerName == values["Name"]) {

            Customer.CustomerId = values["CustomerID"];
            double a = double.parse(values["Balance"]);
            Customer.balance = a.toStringAsFixed(User.decimals);
            Customer.CustomerName = values["Name"].toString();

        } else {
          if (customerName == values["CustomerCode"]) {

              Customer.CustomerId = values["CustomerID"];
              double a = double.parse(values["Balance"]);
              Customer.balance = a.toStringAsFixed(User.decimals);
              Customer.CustomerName = values["Name"].toString();
          }
        }
      });
    }
  }
}