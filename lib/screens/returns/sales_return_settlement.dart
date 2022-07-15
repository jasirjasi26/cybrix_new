// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_flexible_toast/flutter_flexible_toast.dart';
// import 'package:optimist_erp_app/data/customed_details.dart';
// import 'package:optimist_erp_app/data/user_data.dart';
// import 'package:optimist_erp_app/screens/returns/bill.dart';
//
// class ReturnSettlementPage extends StatefulWidget {
//   ReturnSettlementPage(
//       {Key key,
//         this.customerName,
//         this.date,
//         this.values,
//         this.itemCount,
//         this.radioValue})
//       : super(key: key);
//   final int radioValue;
//   final int itemCount;
//   final String date;
//   final String customerName;
//   final Map<String, dynamic> values;
//
//   @override
//   SalesSettlementPageState createState() => SalesSettlementPageState();
// }
//
// class SalesSettlementPageState extends State<ReturnSettlementPage> {
//   var voucherNo = TextEditingController();
//   var billAmount = TextEditingController();
//   var oldBalance = TextEditingController();
//   var paidCash = TextEditingController();
//   var paidCard = TextEditingController();
//   var subTotal = TextEditingController();
//   double finalBalance = 0;
//   var totalDisc = 0.0;
//   double rounoff = 0;
//   DatabaseReference reference;
//   double totalReceived = 0;
//
//   roundOff() {
//
//     double total;
//     setState(() {
//       total = double.parse(subTotal.text);
//       subTotal.text = double.parse(subTotal.text).round().toString();
//       rounoff = double.parse(subTotal.text) - total;
//     });
//   }
//
//   roundDown() {
//     double total;
//     setState(() {
//       total = double.parse(subTotal.text);
//       subTotal.text = double.parse(subTotal.text).floor().toString();
//       rounoff = total - double.parse(subTotal.text);
//     });
//   }
//
//   payOn(String a) {
//
//     setState(() {
//      // finalBalance = double.parse(Customer.balance) - double.parse(subTotal.text);
//       totalReceived = (double.parse(paidCard.text) + double.parse(paidCash.text));
//       finalBalance = double.parse(Customer.balance) - (double.parse(paidCard.text) + double.parse(paidCash.text));
//
//     });
//   }
//
//   addValues() {
//     reference
//         .child("Returns")
//         .child(widget.date)
//         .child(User.vanNo)
//         .child(User.returnNumber)
//         .update(widget.values);
//
//     reference
//       ..child("Returns")
//           .child(widget.date)
//           .child(User.vanNo)
//           .child(voucherNo.text)
//           .child("Items")
//           .once()
//           .then((DataSnapshot snapshot) {
//         List<dynamic> value = snapshot.value;
//         for (int i = 0; i < value.length; i++) {
//           if (value[i] != null) {
//             setState(() {
//               totalDisc =
//                   totalDisc + double.parse(value[i]['DiscAmount'].toString());
//             });
//           }
//         }
//       });
//
//     if (User.returnNumber != voucherNo.text) {
//       reference
//         ..child("Returns")
//             .child(widget.date)
//             .child(User.vanNo)
//             .child(User.returnNumber)
//             .once()
//             .then((DataSnapshot snapshot) {
//           var data = snapshot.value;
//
//           reference
//             ..child("Returns")
//                 .child(widget.date)
//                 .child(User.vanNo)
//                 .child(voucherNo.text)
//                 .set(data);
//
//           reference
//             ..child("Returns")
//                 .child(widget.date)
//                 .child(User.vanNo)
//                 .child(User.returnNumber)
//                 .remove();
//
//           Map<String, String> values = {
//             'Balance': finalBalance.toString(),
//             'Amount': subTotal.text,
//             'CardReceived': paidCard.text,
//             'CashReceived': paidCash.text,
//             'OrderID': voucherNo.text,
//             'RoundOff': rounoff.toStringAsFixed(2),
//             'TotalReceived': totalReceived.toString(),
//             'UpdatedTime': DateTime.now().toString(),
//           };
//
//           reference
//             ..child("Returns")
//                 .child(widget.date)
//                 .child(User.vanNo)
//                 .child(voucherNo.text)
//                 .update(values);
//         });
//     } else {
//       Map<String, String> values = {
//         'Balance': finalBalance.toString(),
//         'Amount': subTotal.text,
//         'CardReceived': paidCard.text,
//         'CashReceived': paidCash.text,
//         'OrderID': voucherNo.text,
//         'RoundOff': rounoff.toStringAsFixed(2),
//         'TotalReceived': totalReceived.toString(),
//         'UpdatedTime': DateTime.now().toString(),
//       };
//
//       reference
//         ..child("Returns")
//             .child(widget.date)
//             .child(User.vanNo)
//             .child(voucherNo.text)
//             .update(values);
//     }
//
//
//     ///update stock///
//     ///
//     reference
//       ..child("Returns")
//           .child(widget.date)
//           .child(User.vanNo)
//           .child(voucherNo.text)
//           .child("Items")
//           .once()
//           .then((DataSnapshot snapshot) {
//         List<dynamic> values = snapshot.value;
//         for (int i = 0; i < values.length ; i++) {
//
//           reference
//               .child("Items")
//               .child(values[i]['ItemID'].toString())
//               .child("RateAndStock")
//               .child(values[i]['Unit'].toString()).child("Stock").child(User.vanNo)
//               .once()
//               .then((DataSnapshot snapshot) {
//             Map<String, dynamic> newStock = {
//               User.vanNo : double.parse(snapshot.value.toString())+double.parse(values[i]['Qty'].toString()),
//             };
//             reference
//                 .child("Items")
//                 .child(values[i]['ItemID'].toString())
//                 .child("RateAndStock")
//                 .child(values[i]['Unit'].toString()).child("Stock").update(newStock);
//
//           });
//         }
//       });
//
//     ///Update Customer Balance
//     ///
//     Map<String, dynamic> updateBalance = {
//       'Balance': finalBalance,
//     };
//     reference
//         .child("Customers")
//         .child(widget.values['CustomerID'])
//         .update(updateBalance);
//
//
//     FlutterFlexibleToast.showToast(
//         message: "Added to Returns",
//         toastGravity: ToastGravity.BOTTOM,
//         icon: ICON.SUCCESS,
//         radius: 50,
//         elevation: 10,
//         imageSize: 20,
//         textColor: Colors.white,
//         backgroundColor: Colors.black,
//         timeInSeconds: 2);
//
//     ///updating the voucher number
//
//     String lastVoucher = voucherNo.text.replaceAll(User.returnStarting, "");
//     reference
//       ..child("Vouchers")
//           .child(User.vanNo)
//           .child("ReturnNumber")
//           .remove()
//           .whenComplete(() => {
//         reference
//           ..child("Vouchers")
//               .child(User.vanNo)
//               .child("ReturnNumber")
//               .set(lastVoucher.toString())
//       });
//
//
//     Navigator.push(context, MaterialPageRoute(builder: (context) {
//       return BillPage(
//         customerName: widget.customerName,
//         voucherNumber: voucherNo.text,
//         date: widget.date,
//         billAmount: widget.values['BillAmount'],
//         customerCode: widget.values['CustomerID'],
//         back: false,
//       );
//     }));
//   }
//
//   getVoucherNumber() async {
//     await reference
//         .child("Vouchers")
//         .child(User.vanNo)
//         .once()
//         .then((DataSnapshot snapshot) {
//       Map<dynamic, dynamic> values = snapshot.value;
//       values.forEach((key, values) {
//         setState(() {
//           if (key.toString() == "ReturnNumber") {
//             voucherNo.text = User.returnStarting +
//                 (int.parse(values.toString()) + 1).toString();
//           }
//         });
//       });
//     });
//   }
//
//   void initState() {
//     // TODO: implement initState
//
//     reference = FirebaseDatabase.instance
//         .reference()
//         .child("Companies")
//         .child(User.database);
//
//     getVoucherNumber();
//
//     setState(() {
//       oldBalance.text = Customer.balance;
//       billAmount.text = widget.values['Amount'].toString();
//       subTotal.text = widget.values['Amount'].toString();
//       paidCash.text = "0";
//       paidCard.text = "0";
//       finalBalance =
//           double.parse(Customer.balance) + double.parse(subTotal.text);
//     });
//
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: buildAppBar(context),
//       body: WillPopScope(
//         onWillPop: () async {
//           // You can do some work here.
//           // Returning true allows the pop to happen, returning false prevents it.
//           reference
//               .child("Bills")
//               .child(widget.date)
//               .child(User.vanNo)
//               .child(User.voucherNumber)
//               .remove();
//           return true;
//         },
//         child: ListView(
//           children: [
//             SizedBox(
//               height: 20,
//             ),
//             Padding(
//               padding: const EdgeInsets.all(5.0),
//               child: Row(
//                 children: [
//                   SizedBox(
//                     width: 30,
//                   ),
//                   Container(
//                       height: 25,
//                       width: 25,
//                       child: Image.asset("assets/images/voucher.png",
//                           fit: BoxFit.scaleDown, color: Colors.black)),
//                   SizedBox(
//                     width: 10,
//                   ),
//                   Container(
//                     width: MediaQuery.of(context).size.width * 0.8,
//                     height: 50,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(16.0),
//                       color: const Color(0xffffffff),
//                       boxShadow: [
//                         BoxShadow(
//                           color: const Color(0x29000000),
//                           offset: Offset(6, 3),
//                           blurRadius: 12,
//                         ),
//                       ],
//                     ),
//                     child: TextFormField(
//                         controller: voucherNo,
//                         decoration: InputDecoration(
//                           hintText: 'Voucher Number',
//                           //filled: true,
//                           border: InputBorder.none,
//                           contentPadding: EdgeInsets.only(
//                               left: 15, bottom: 15, top: 15, right: 15),
//                           filled: false,
//                           isDense: false,
//                         )),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(
//               height: 20,
//             ),
//             Padding(
//               padding: const EdgeInsets.all(5.0),
//               child: Row(
//                 children: [
//                   SizedBox(
//                     width: 30,
//                   ),
//                   Container(
//                       height: 25,
//                       width: 25,
//                       child: Image.asset("assets/images/balance.png",
//                           fit: BoxFit.scaleDown, color: Colors.black)),
//                   SizedBox(
//                     width: 10,
//                   ),
//                   Column(
//                     children: [
//                       Container(
//                           width: MediaQuery.of(context).size.width * 0.35 - 10,
//                           height: 50,
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(16.0),
//                             color: const Color(0xffffffff),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: const Color(0x29000000),
//                                 offset: Offset(6, 3),
//                                 blurRadius: 12,
//                               ),
//                             ],
//                           ),
//                           child: Padding(
//                             padding: EdgeInsets.only(
//                                 left: 15, bottom: 15, top: 15, right: 15),
//                             child: Text(oldBalance.text),
//                           )),
//                       Text(
//                         "Old Balance",
//                         style: TextStyle(fontSize: 14, color: Colors.grey),
//                       )
//                     ],
//                   ),
//                   SizedBox(
//                     width: 10,
//                   ),
//                   Container(
//                       height: 25,
//                       width: 25,
//                       child: Image.asset("assets/images/balance.png",
//                           fit: BoxFit.scaleDown, color: Colors.black)),
//                   SizedBox(
//                     width: 10,
//                   ),
//                   Column(
//                     children: [
//                       Container(
//                           width: MediaQuery.of(context).size.width * 0.35 - 10,
//                           height: 50,
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(16.0),
//                             color: const Color(0xffffffff),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: const Color(0x29000000),
//                                 offset: Offset(6, 3),
//                                 blurRadius: 12,
//                               ),
//                             ],
//                           ),
//                           child: Padding(
//                             padding: EdgeInsets.only(
//                                 left: 15, bottom: 15, top: 15, right: 15),
//                             child: Text(billAmount.text),
//                           )),
//                       Text(
//                         "Bill Amount",
//                         style: TextStyle(fontSize: 14, color: Colors.grey),
//                       )
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Row(
//                 children: [
//                   SizedBox(
//                     width: 25,
//                   ),
//                   Container(
//                       height: 30,
//                       width: 30,
//                       child: Image.asset(
//                         "assets/images/cashrecived.png",
//                         fit: BoxFit.fill,
//                         //    color: Colors.black
//                       )),
//                   Text(
//                     "    Cash Received",
//                     style: TextStyle(fontSize: 18),
//                   )
//                 ],
//               ),
//             ),
//             SizedBox(
//               height: 10,
//             ),
//             Padding(
//               padding: const EdgeInsets.all(5.0),
//               child: Row(
//                 children: [
//                   SizedBox(
//                     width: 30,
//                   ),
//                   Column(
//                     children: [
//                       Container(
//                         width: MediaQuery.of(context).size.width * 0.45 - 10,
//                         height: 50,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(16.0),
//                           color: const Color(0xffffffff),
//                           boxShadow: [
//                             BoxShadow(
//                               color: const Color(0x29000000),
//                               offset: Offset(6, 3),
//                               blurRadius: 12,
//                             ),
//                           ],
//                         ),
//                         child: Row(
//                           children: [
//                             Padding(
//                               padding: const EdgeInsets.all(8.0),
//                               child: Container(
//                                   height: 25,
//                                   width: 25,
//                                   child: Image.asset(
//                                     "assets/images/money.png",
//                                     fit: BoxFit.scaleDown,
//                                     //    color: Colors.black
//                                   )),
//                             ),
//                             Container(
//                               width: MediaQuery.of(context).size.width * 0.3,
//                               child: TextFormField(
//                                   controller: paidCash,
//                                   onChanged: payOn,
//                                   decoration: InputDecoration(
//                                     hintText: '',
//                                     //filled: true,
//                                     border: InputBorder.none,
//                                     contentPadding: EdgeInsets.only(
//                                         left: 15,
//                                         bottom: 15,
//                                         top: 15,
//                                         right: 15),
//                                     filled: false,
//                                     isDense: false,
//                                   )),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Text(
//                         "Paid via cash",
//                         style: TextStyle(fontSize: 14, color: Colors.grey),
//                       )
//                     ],
//                   ),
//                   SizedBox(
//                     width: 10,
//                   ),
//                   Column(
//                     children: [
//                       Container(
//                         width: MediaQuery.of(context).size.width * 0.45 - 10,
//                         height: 50,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(16.0),
//                           color: const Color(0xffffffff),
//                           boxShadow: [
//                             BoxShadow(
//                               color: const Color(0x29000000),
//                               offset: Offset(6, 3),
//                               blurRadius: 12,
//                             ),
//                           ],
//                         ),
//                         child: Row(
//                           children: [
//                             Padding(
//                               padding: const EdgeInsets.all(8.0),
//                               child: Container(
//                                   height: 25,
//                                   width: 25,
//                                   child: Image.asset(
//                                     "assets/images/card.png",
//                                     fit: BoxFit.scaleDown,
//                                     //    color: Colors.black
//                                   )),
//                             ),
//                             Container(
//                               width: MediaQuery.of(context).size.width * 0.3,
//                               child: TextFormField(
//                                   controller: paidCard,
//                                   onChanged: payOn,
//                                   decoration: InputDecoration(
//                                     hintText: '',
//                                     border: InputBorder.none,
//                                     contentPadding: EdgeInsets.only(
//                                         left: 15,
//                                         bottom: 15,
//                                         top: 15,
//                                         right: 15),
//                                     filled: false,
//                                     isDense: false,
//                                   )),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Text(
//                         "Paid via card",
//                         style: TextStyle(fontSize: 14, color: Colors.grey),
//                       )
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(
//               height: 20,
//             ),
//             Row(
//               children: [
//                 SizedBox(
//                   width: 20,
//                 ),
//                 Text(
//                   '   Subtotal  ',
//                   style: TextStyle(
//                     fontFamily: 'Arial',
//                     fontSize: 18,
//                     color: const Color(0xff5b5b5b),
//                   ),
//                   textAlign: TextAlign.left,
//                 ),
//                 SizedBox(
//                   width: 10,
//                 ),
//                 Container(
//                   width: MediaQuery.of(context).size.width * 0.45,
//                   height: 50,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(16.0),
//                     color: const Color(0xffffffff),
//                     boxShadow: [
//                       BoxShadow(
//                         color: const Color(0x29000000),
//                         offset: Offset(6, 3),
//                         blurRadius: 12,
//                       ),
//                     ],
//                   ),
//                   child: Container(
//                       width: MediaQuery.of(context).size.width * 0.35,
//                       child: Padding(
//                         padding: EdgeInsets.only(
//                             left: 15, bottom: 15, top: 15, right: 15),
//                         child: Text(subTotal.text),
//                       )),
//                 ),
//                 SizedBox(
//                   width: 15,
//                 ),
//                 Column(
//                   children: [
//                     Row(
//                       children: [
//                         GestureDetector(
//                           onTap: () {
//                             roundDown();
//                           },
//                           child: Container(
//                             height: 35,
//                             width: 35,
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(5.0),
//                               color: const Color(0xff8561f0),
//                             ),
//                             child: Image.asset("assets/images/back.png",
//                                 fit: BoxFit.scaleDown, color: Colors.white),
//                           ),
//                         ),
//                         SizedBox(
//                           width: 10,
//                         ),
//                         GestureDetector(
//                           onTap: () {
//                             roundOff();
//                           },
//                           child: Container(
//                             height: 35,
//                             width: 35,
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(5.0),
//                               color: const Color(0xff8561f0),
//                             ),
//                             child: Image.asset("assets/images/front.png",
//                                 fit: BoxFit.scaleDown, color: Colors.white),
//                           ),
//                         )
//                       ],
//                     ),
//                     Text(
//                       "Round Off",
//                       style: TextStyle(
//                         fontFamily: 'Arial',
//                         fontSize: 12,
//                         color: const Color(0xff5b5b5b),
//                       ),
//                     )
//                   ],
//                 ),
//               ],
//             ),
//             Padding(
//               padding: const EdgeInsets.only(
//                   left: 10.0, right: 50, bottom: 5, top: 25),
//               child: Row(
//                 children: [
//                   SizedBox(
//                     width: 25,
//                   ),
//                   Container(
//                       height: 20,
//                       width: 20,
//                       child: Image.asset(
//                         "assets/images/percentage.png",
//                         fit: BoxFit.scaleDown,
//                       )),
//                   SizedBox(
//                     width: 20,
//                   ),
//                   Text(
//                     "Tax :   " + widget.values['TaxAmount'].toString(),
//                     style: TextStyle(color: Colors.black, fontSize: 18),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(
//               height: 30,
//             ),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Row(
//                 children: [
//                   Spacer(),
//                   Text(
//                     'Grand Total  ',
//                     style: TextStyle(
//                       fontFamily: 'Arial',
//                       fontSize: 14,
//                       color: const Color(0xff5b5b5b),
//                     ),
//                     textAlign: TextAlign.left,
//                   ),
//                   Container(
//                     width: 150,
//                     height: 40,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(8.0),
//                       gradient: LinearGradient(
//                         begin: Alignment(0.0, -4.12),
//                         end: Alignment(0.0, 1.0),
//                         colors: [
//                           const Color(0xffffffff),
//                           const Color(0xfffaa731)
//                         ],
//                         stops: [0.0, 1.0],
//                       ),
//                       boxShadow: [
//                         BoxShadow(
//                           color: const Color(0xfffae7cb),
//                           offset: Offset(6, 3),
//                           blurRadius: 6,
//                         ),
//                       ],
//                     ),
//                     child: Center(child: Text(subTotal.text)),
//                   ),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Row(
//                 children: [
//                   Spacer(),
//                   Text(
//                     'Balance   ',
//                     style: TextStyle(
//                       fontFamily: 'Arial',
//                       fontSize: 14,
//                       color: const Color(0xff5b5b5b),
//                     ),
//                     textAlign: TextAlign.left,
//                   ),
//                   Container(
//                     width: 150,
//                     height: 40,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(8.0),
//                       gradient: LinearGradient(
//                         begin: Alignment(0.0, -4.12),
//                         end: Alignment(0.0, 1.0),
//                         colors: [
//                           const Color(0xffffffff),
//                           const Color(0xfffb4ce5)
//                         ],
//                         stops: [0.0, 1.0],
//                       ),
//                       boxShadow: [
//                         BoxShadow(
//                           color: const Color(0xfffae7cb),
//                           offset: Offset(6, 3),
//                           blurRadius: 6,
//                         ),
//                       ],
//                     ),
//                     child: Center(child: Text(finalBalance.toString())),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(
//               height: 40,
//             ),
//             Center(
//               child: GestureDetector(
//                 onTap: () {
//                   addValues();
//                 },
//                 child: Container(
//                   height: 50,
//                   width: 100,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(8.0),
//                     gradient: LinearGradient(
//                       begin: Alignment(0.01, -0.72),
//                       end: Alignment(0.0, 1.0),
//                       colors: [
//                         const Color(0xff385194),
//                         const Color(0xff182d66)
//                       ],
//                       stops: [0.0, 1.0],
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: const Color(0x80182d66),
//                         offset: Offset(6, 3),
//                         blurRadius: 6,
//                       ),
//                     ],
//                   ),
//                   child: Center(
//                     child: Text(
//                       'Save',
//                       style: TextStyle(
//                         fontFamily: 'Arial',
//                         fontSize: 18,
//                         color: const Color(0xfff7fdfd),
//                       ),
//                       textAlign: TextAlign.left,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   AppBar buildAppBar(BuildContext context) {
//     return AppBar(
//       backgroundColor: Colors.white,
//       centerTitle: true,
//       automaticallyImplyLeading: false,
//       title: Text(
//         "Return Settlements",
//         style: TextStyle(color: Colors.black),
//       ),
//       iconTheme: IconThemeData(
//         color: Colors.black, //change your color here
//       ),
//       elevation: 0,
//       titleSpacing: 0,
//       toolbarHeight: 80,
//     );
//   }
// }
