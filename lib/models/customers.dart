// To parse this JSON data, do
//
//     final customers = customersFromJson(jsonString);
// @dart=2.9
import 'dart:convert';

Map<String, Customers> customersFromJson(String str) => Map.from(json.decode(str)).map((k, v) => MapEntry<String, Customers>(k, Customers.fromJson(v)));

String customersToJson(Map<String, Customers> data) => json.encode(Map.from(data).map((k, v) => MapEntry<String, dynamic>(k, v.toJson())));

class Customers {
  Customers({
    this.address,
    this.arabicName,
    this.balance,
    this.customerCode,
    this.customerId,
    this.employeeMobile,
    this.gstno,
    this.mobileNumber,
    this.name,
    this.trnno,
    this.vatno,
  });

  String address;
  ArabicName arabicName;
  String balance;
  String customerCode;
  String customerId;
  EmployeeMobile employeeMobile;
  String gstno;
  String mobileNumber;
  String name;
  String trnno;
  String vatno;

  factory Customers.fromJson(Map<String, dynamic> json) => Customers(
    address: json["Address"],
    arabicName: arabicNameValues.map[json["ArabicName"]],
    balance: json["Balance"],
    customerCode: json["CustomerCode"],
    customerId: json["CustomerID"],
    employeeMobile: employeeMobileValues.map[json["EmployeeMobile"]],
    gstno: json["GSTNO"],
    mobileNumber: json["MobileNumber"],
    name: json["Name"],
    trnno: json["TRNNO"],
    vatno: json["VATNO"],
  );

  Map<String, dynamic> toJson() => {
    "Address": address,
    "ArabicName": arabicNameValues.reverse[arabicName],
    "Balance": balance,
    "CustomerCode": customerCode,
    "CustomerID": customerId,
    "EmployeeMobile": employeeMobileValues.reverse[employeeMobile],
    "GSTNO": gstno,
    "MobileNumber": mobileNumber,
    "Name": name,
    "TRNNO": trnno,
    "VATNO": vatno,
  };
}

enum ArabicName { CASH_ACCOUNT, EMPTY, NEW_BRANCH, THE_0581284077 }

final arabicNameValues = EnumValues({
  "Cash Account": ArabicName.CASH_ACCOUNT,
  "": ArabicName.EMPTY,
  "NEW BRANCH": ArabicName.NEW_BRANCH,
  "0581284077": ArabicName.THE_0581284077
});

enum EmployeeMobile { THE_971551649870, EMPTY, THE_971554181190, THE_971565870365, THE_971527277011, THE_971563154307, THE_971551314043, THE_971561064786 }

final employeeMobileValues = EnumValues({
  "": EmployeeMobile.EMPTY,
  "+971527277011": EmployeeMobile.THE_971527277011,
  "+971551314043": EmployeeMobile.THE_971551314043,
  "+971551649870": EmployeeMobile.THE_971551649870,
  "+971554181190": EmployeeMobile.THE_971554181190,
  "+971561064786": EmployeeMobile.THE_971561064786,
  "+971563154307": EmployeeMobile.THE_971563154307,
  "+971565870365": EmployeeMobile.THE_971565870365
});

class EnumValues<T> {
  Map<String, T> map;
  Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    if (reverseMap == null) {
      reverseMap = map.map((k, v) => new MapEntry(v, k));
    }
    return reverseMap;
  }
}
