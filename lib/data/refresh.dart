import 'dart:convert';

import 'package:api_cache_manager/models/cache_db_model.dart';
import 'package:api_cache_manager/utils/cache_manager.dart';
import 'package:cybrix/data/user_data.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flexible_toast/flutter_flexible_toast.dart';

class Refresh{
  refresh() async {
    if (await DataConnectionChecker().hasConnection) {
      await FirebaseDatabase.instance
          .reference()
          .child("Companies")
          .child(User.database)
          .child("Items").once().then((DataSnapshot snapshot) async {
        List<dynamic> values = snapshot.value;

        APICacheDBModel cacheDBModel =
        new APICacheDBModel(key: "itemData", syncData: jsonEncode(values));
        await APICacheManager().addCacheData(cacheDBModel);
      }).whenComplete(() => {
      FlutterFlexibleToast.showToast(
      message: "Update Done",
      toastGravity: ToastGravity.BOTTOM,
      icon: ICON.SUCCESS,
      radius: 50,
      elevation: 10,
      imageSize: 15,
      textColor: Colors.white,
      backgroundColor: Colors.black,
      timeInSeconds: 2)
      });


    }
  }
}