// @dart=2.9
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../ui_elements/main_drawer.dart';
import 'all_products.dart';

class ProductPage extends StatefulWidget {
  ProductPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  ProductPageState createState() => ProductPageState();
}

class ProductPageState extends State<ProductPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: MainDrawer(),
      backgroundColor: Colors.white,
      appBar: buildAppBar(context),
      body: ListView(
        children: [
          SizedBox(
            height: 10,
          ),
          searchRow(),
          SizedBox(
            height: 10,
          ),
          homeData()
        ],
      ),
    );
  }

  searchRow() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 60,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                color: const Color(0xffffffff),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x29000000),
                    offset: Offset(6, 3),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: TextFormField(
                  // controller: _username,
                  decoration: InputDecoration(
                hintText: 'Enter product name here',
                //filled: true,
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.only(left: 15, bottom: 5, top: 15, right: 15),
                filled: false,
                isDense: false,
                prefixIcon: Icon(
                  Icons.search,
                  size: 25.0,
                  color: Colors.grey,
                ),
              )),
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.only(left: 8.0, right: 8),
          //   child: Column(
          //     children: [
          //       Spacer(),
          //       GestureDetector(
          //         child: Container(
          //             height: 30,
          //             width: 45,
          //             decoration: BoxDecoration(
          //               image: DecorationImage(image: AssetImage(
          //                 "assets/images/filter.png",
          //                 //fit: BoxFit.scaleDown,
          //                 //    color: Colors.white
          //               ))
          //             ),
          //             child:DropdownButton(
          //               isDense: true,
          //               //itemHeight: 50,
          //               iconSize: 0,
          //               isExpanded: true,
          //               hint: Text('Please choose sales type'),
          //               // Not necessary for Option 1
          //               value: _selectedLocation,
          //               onChanged: (newValue) {
          //                 setState(() {
          //                   _selectedLocation = newValue;
          //                 });
          //               },
          //               items: _locations.map((location) {
          //                 return DropdownMenuItem(
          //                   child: Text(location,style: TextStyle(fontSize: 1),),
          //                   value: location,
          //                 );
          //               }).toList(),
          //             ),
          //             // child: Image.asset(
          //             //   "assets/images/filter.png",
          //             //   fit: BoxFit.scaleDown,
          //             //   //    color: Colors.white
          //             // )
          //         ),
          //       ),
          //       Spacer(),
          //       Text("Filter")
          //     ],
          //   ),
          // ),
          // Padding(
          //   padding: const EdgeInsets.only(left: 8.0, right: 8),
          //   child: Column(
          //     children: [
          //       Spacer(),
          //       Container(
          //           height: 30,
          //           width: 30,
          //           child: Image.asset(
          //             "assets/images/scan.png",
          //             fit: BoxFit.scaleDown,
          //             //    color: Colors.white
          //           )),
          //       Spacer(),
          //       Text("Scan")
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

  homeData() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            height: 150,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              color: const Color(0xffffffff),
              boxShadow: [
                BoxShadow(
                  color: const Color(0x29000000),
                  offset: Offset(6, 3),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Column(
              children: [
                Spacer(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text(
                        'Total Stock',
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 15,
                          color: const Color(0xff868383),
                        ),
                        textAlign: TextAlign.left,
                      ),
                      Spacer(),
                      Text(
                        'Stock In Hand',
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 15,
                          color: const Color(0xff868383),
                        ),
                        textAlign: TextAlign.left,
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text(
                        '128',
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 25,
                          color: const Color(0xff1d336c),
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      Spacer(),
                      Text(
                        '2,350',
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 25,
                          color: const Color(0xff1d336c),
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.left,
                      )
                    ],
                  ),
                ),
                Spacer(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          padding: const EdgeInsets.all(5.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4.0),
                            color: const Color(0xffc4f0c6),
                          ),
                          child: Row(
                            children: [
                              Container(
                                height: 10,
                                width: 10,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3.0),
                                  color: const Color(0xff388e3c),
                                ),
                              ),
                              Text(
                                '  +5.44 ',
                                style: TextStyle(
                                  fontFamily: 'Arial',
                                  fontSize: 10,
                                  color: const Color(0xff388e3c),
                                ),
                                textAlign: TextAlign.left,
                              )
                            ],
                          ),
                        ),
                      ),
                      Spacer(),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          padding: const EdgeInsets.all(5.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4.0),
                            color: const Color(0xffd0eff9),
                          ),
                          child: Row(
                            children: [
                              Container(
                                height: 10,
                                width: 10,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3.0),
                                  color: const Color(0xff22bef1),
                                ),
                              ),
                              Text(
                                '  +2.68 ',
                                style: TextStyle(
                                  fontFamily: 'Arial',
                                  fontSize: 10,
                                  color: const Color(0xff22bef1),
                                ),
                                textAlign: TextAlign.left,
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        SizedBox(
          height: 20,
        ),
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Product Group List',
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 18,
                  color: const Color(0xff868383),
                ),
                textAlign: TextAlign.left,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return AllProductPage();
                  }));
                },
                child: Container(
                  height: 100,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    color: const Color(0xffffffff),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0x29000000),
                        offset: Offset(6, 3),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Positioned(
                      //     bottom: 10,
                      //     right: 25,
                      //     child: Row(
                      //       children: [
                      //         Text(
                      //           'Total Sales : ',
                      //           style: TextStyle(
                      //             fontFamily: 'Arial',
                      //             fontSize: 10,
                      //             color: const Color(0xff868383),
                      //           ),
                      //           textAlign: TextAlign.left,
                      //         ),
                      //         Text(
                      //           ' 263 ',
                      //           style: TextStyle(
                      //             fontFamily: 'Arial',
                      //             fontSize: 10,
                      //             color: const Color(0xff388e3c),
                      //           ),
                      //           textAlign: TextAlign.left,
                      //         ),
                      //         Container(
                      //             height: 10,
                      //             width: 10,
                      //             child: Image.asset(
                      //               "assets/images/up.png",
                      //               fit: BoxFit.scaleDown,
                      //               //    color: Colors.white
                      //             )),
                      //       ],
                      //     )
                      // ),
                      Center(
                        child: Row(
                          children: [
                            SizedBox(
                              width: 20,
                            ),
                            Container(
                              height: 50,
                              width: 50,
                              child: Center(
                                child: Container(
                                    height: 50,
                                    width: 50,
                                    child: Image.asset(
                                      "assets/images/veg_icon.png",
                                      fit: BoxFit.cover,
                                      //    color: Colors.white
                                    )),
                              ),
                            ),
                            Text(
                              '  Vegitables',
                              style: TextStyle(
                                fontFamily: 'Arial',
                                fontSize: 16,
                                color: const Color(0xff868383),
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.left,
                            ),
                            Spacer(),
                            Container(
                              height: 30,
                              width: 30,
                              child: Center(
                                child: Container(
                                    height: 20,
                                    width: 20,
                                    child: Image.asset(
                                      "assets/images/arrow.png",
                                      fit: BoxFit.scaleDown,
                                      //    color: Colors.white
                                    )),
                              ),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              ///First Line
              ///
              SizedBox(
                height: 20,
              ),

              Container(
                height: 100,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  color: const Color(0xffffffff),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0x29000000),
                      offset: Offset(6, 3),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Positioned(
                    //     bottom: 10,
                    //     right: 25,
                    //     child: Row(
                    //       children: [
                    //         Text(
                    //           'Total Sales : ',
                    //           style: TextStyle(
                    //             fontFamily: 'Arial',
                    //             fontSize: 10,
                    //             color: const Color(0xff868383),
                    //           ),
                    //           textAlign: TextAlign.left,
                    //         ),
                    //         Text(
                    //           ' 263 ',
                    //           style: TextStyle(
                    //             fontFamily: 'Arial',
                    //             fontSize: 10,
                    //             color: const Color(0xff388e3c),
                    //           ),
                    //           textAlign: TextAlign.left,
                    //         ),
                    //         Container(
                    //             height: 10,
                    //             width: 10,
                    //             child: Image.asset(
                    //               "assets/images/up.png",
                    //               fit: BoxFit.scaleDown,
                    //               //    color: Colors.white
                    //             )),
                    //       ],
                    //     )),
                    Center(
                      child: Row(
                        children: [
                          SizedBox(
                            width: 20,
                          ),
                          Container(
                            height: 50,
                            width: 50,
                            child: Center(
                              child: Container(
                                  height: 50,
                                  width: 50,
                                  child: Image.asset(
                                    "assets/images/fruit_icon.png",
                                    fit: BoxFit.cover,
                                    //    color: Colors.white
                                  )),
                            ),
                          ),
                          Text(
                            '  Fruits',
                            style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 16,
                              color: const Color(0xff868383),
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.left,
                          ),
                          Spacer(),
                          Container(
                            height: 30,
                            width: 30,
                            child: Center(
                              child: Container(
                                  height: 20,
                                  width: 20,
                                  child: Image.asset(
                                    "assets/images/arrow.png",
                                    fit: BoxFit.scaleDown,
                                    //    color: Colors.white
                                  )),
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              ///2nd line
              ///
              SizedBox(
                height: 20,
              ),
              Container(
                height: 100,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  color: const Color(0xffffffff),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0x29000000),
                      offset: Offset(6, 3),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Positioned(
                    //     bottom: 10,
                    //     right: 25,
                    //     child: Row(
                    //       children: [
                    //         Text(
                    //           'Total Sales : ',
                    //           style: TextStyle(
                    //             fontFamily: 'Arial',
                    //             fontSize: 10,
                    //             color: const Color(0xff868383),
                    //           ),
                    //           textAlign: TextAlign.left,
                    //         ),
                    //         Text(
                    //           ' 263 ',
                    //           style: TextStyle(
                    //             fontFamily: 'Arial',
                    //             fontSize: 10,
                    //             color: const Color(0xff388e3c),
                    //           ),
                    //           textAlign: TextAlign.left,
                    //         ),
                    //         Container(
                    //             height: 10,
                    //             width: 10,
                    //             child: Image.asset(
                    //               "assets/images/up.png",
                    //               fit: BoxFit.scaleDown,
                    //               //    color: Colors.white
                    //             )),
                    //       ],
                    //     )),
                    Center(
                      child: Row(
                        children: [
                          SizedBox(
                            width: 20,
                          ),
                          Container(
                            height: 50,
                            width: 50,
                            child: Center(
                              child: Container(
                                  height: 50,
                                  width: 50,
                                  child: Image.asset(
                                    "assets/images/spices_icon.png",
                                    fit: BoxFit.cover,
                                    //    color: Colors.white
                                  )),
                            ),
                          ),
                          Text(
                            '  Spices',
                            style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 16,
                              color: const Color(0xff868383),
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.left,
                          ),
                          Spacer(),
                          Container(
                            height: 30,
                            width: 30,
                            child: Center(
                              child: Container(
                                  height: 20,
                                  width: 20,
                                  child: Image.asset(
                                    "assets/images/arrow.png",
                                    fit: BoxFit.scaleDown,
                                    //    color: Colors.white
                                  )),
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: widget.title == "title" ? Colors.blue[900] : Colors.white,
      centerTitle: false,
      title: widget.title == "title" ? Text("All Products") : Text(" All Products",style: TextStyle(color: Colors.black),),
      elevation: widget.title == "title" ? 1.0 : 0,
      titleSpacing: 0,
      toolbarHeight: 70,
      leading: widget.title == "title" ? Builder(
        builder: (context) => IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ) : Container(
        child: GestureDetector(
          onTap: () {
            _scaffoldKey.currentState.openDrawer();
          },
          child: Builder(
            builder: (context) => Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
              child: Container(
                child: Image.asset(
                  'assets/images/homebox.png',
                  height: 30,
                  width: 30,
                  //color: MyTheme.dark_grey,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
