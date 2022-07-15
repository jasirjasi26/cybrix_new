// To parse this JSON data, do
//
//     final items = itemsFromJson(jsonString);
// @dart=2.9
import 'dart:convert';

List<Items> itemsFromJson(String str) => List<Items>.from(json.decode(str).map((x) => Items.fromJson(x)));

String itemsToJson(List<Items> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Items {
  Items({
    this.additionalTax,
    this.additionalTaxInclusive,
    this.code,
    this.description,
    this.gst,
    this.gstInclusive,
    this.itemId,
    this.itemName,
    this.minimumSalesRate,
    this.rateAndStock,
    this.saleUnit,
    this.salesStock,
    this.totalStock,
    this.vat,
    this.vatInclusive,
  });

  String additionalTax;
  Inclusive additionalTaxInclusive;
  String code;
  String description;
  String gst;
  Inclusive gstInclusive;
  String itemId;
  String itemName;
  String minimumSalesRate;
  RateAndStock rateAndStock;
  SaleUnit saleUnit;
  String salesStock;
  String totalStock;
  String vat;
  Inclusive vatInclusive;

  factory Items.fromJson(Map<String, dynamic> json) => Items(
    additionalTax: json["AdditionalTax"],
    additionalTaxInclusive: inclusiveValues.map[json["AdditionalTaxInclusive"]],
    code: json["Code"],
    description: json["Description"],
    gst: json["GST"],
    gstInclusive: inclusiveValues.map[json["GSTInclusive"]],
    itemId: json["ItemID"],
    itemName: json["ItemName"],
    minimumSalesRate: json["MinimumSalesRate"] == null ? null : json["MinimumSalesRate"],
    rateAndStock: RateAndStock.fromJson(json["RateAndStock"]),
    saleUnit: saleUnitValues.map[json["SaleUnit"]],
    salesStock: json["SalesStock"],
    totalStock: json["TotalStock"],
    vat: json["VAT"],
    vatInclusive: inclusiveValues.map[json["VATInclusive"]],
  );

  Map<String, dynamic> toJson() => {
    "AdditionalTax": additionalTax,
    "AdditionalTaxInclusive": inclusiveValues.reverse[additionalTaxInclusive],
    "Code": code,
    "Description": description,
    "GST": gst,
    "GSTInclusive": inclusiveValues.reverse[gstInclusive],
    "ItemID": itemId,
    "ItemName": itemName,
    "MinimumSalesRate": minimumSalesRate == null ? null : minimumSalesRate,
    "RateAndStock": rateAndStock.toJson(),
    "SaleUnit": saleUnitValues.reverse[saleUnit],
    "SalesStock": salesStock,
    "TotalStock": totalStock,
    "VAT": vat,
    "VATInclusive": inclusiveValues.reverse[vatInclusive],
  };
}

enum Inclusive { DISABLED }

final inclusiveValues = EnumValues({
  "Disabled": Inclusive.DISABLED
});

class RateAndStock {
  RateAndStock({
    this.pcs,
    this.bag,
    this.box,
    this.pack,
    this.kg,
    this.ctn,
    this.rateAndStockBox,
    this.rateAndStockDefault,
  });

  Bag pcs;
  Bag bag;
  Bag box;
  Bag pack;
  Bag kg;
  Bag ctn;
  Bag rateAndStockBox;
  Bag rateAndStockDefault;

  factory RateAndStock.fromJson(Map<String, dynamic> json) => RateAndStock(
    pcs: json["PCS"] == null ? null : Bag.fromJson(json["PCS"]),
    bag: json["BAG"] == null ? null : Bag.fromJson(json["BAG"]),
    box: json["Box"] == null ? null : Bag.fromJson(json["Box"]),
    pack: json["Pack"] == null ? null : Bag.fromJson(json["Pack"]),
    kg: json["KG"] == null ? null : Bag.fromJson(json["KG"]),
    ctn: json["CTN"] == null ? null : Bag.fromJson(json["CTN"]),
    rateAndStockBox: json["box"] == null ? null : Bag.fromJson(json["box"]),
    rateAndStockDefault: json["Default"] == null ? null : Bag.fromJson(json["Default"]),
  );

  Map<String, dynamic> toJson() => {
    "PCS": pcs == null ? null : pcs.toJson(),
    "BAG": bag == null ? null : bag.toJson(),
    "Box": box == null ? null : box.toJson(),
    "Pack": pack == null ? null : pack.toJson(),
    "KG": kg == null ? null : kg.toJson(),
    "CTN": ctn == null ? null : ctn.toJson(),
    "box": rateAndStockBox == null ? null : rateAndStockBox.toJson(),
    "Default": rateAndStockDefault == null ? null : rateAndStockDefault.toJson(),
  };
}

class Bag {
  Bag({
    this.minimumSalesRate,
    this.purchaseRate,
    this.rate,
    this.stock,
  });

  String minimumSalesRate;
  String purchaseRate;
  String rate;
  List<String> stock;

  factory Bag.fromJson(Map<String, dynamic> json) => Bag(
    minimumSalesRate: json["MinimumSalesRate"],
    purchaseRate: json["PurchaseRate"],
    rate: json["Rate"],
    stock: List<String>.from(json["Stock"].map((x) => x == null ? null : x)),
  );

  Map<String, dynamic> toJson() => {
    "MinimumSalesRate": minimumSalesRate,
    "PurchaseRate": purchaseRate,
    "Rate": rate,
    "Stock": List<dynamic>.from(stock.map((x) => x == null ? null : x)),
  };
}

enum SaleUnit { PCS, KG, BAG, DEFAULT }

final saleUnitValues = EnumValues({
  "BAG": SaleUnit.BAG,
  "Default": SaleUnit.DEFAULT,
  "KG": SaleUnit.KG,
  "PCS": SaleUnit.PCS
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
