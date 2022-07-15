// To parse this JSON data, do
//
//     final saletypes = saletypesFromJson(jsonString);
// @dart=2.9
import 'dart:convert';

Map<String, Saletypes> saletypesFromJson(String str) => Map.from(json.decode(str)).map((k, v) => MapEntry<String, Saletypes>(k, Saletypes.fromJson(v)));

String saletypesToJson(Map<String, Saletypes> data) => json.encode(Map.from(data).map((k, v) => MapEntry<String, dynamic>(k, v.toJson())));

class Saletypes {
  Saletypes({
    this.id,
    this.name,
  });

  String id;
  String name;

  factory Saletypes.fromJson(Map<String, dynamic> json) => Saletypes(
    id: json["ID"],
    name: json["Name"],
  );

  Map<String, dynamic> toJson() => {
    "ID": id,
    "Name": name,
  };
}
