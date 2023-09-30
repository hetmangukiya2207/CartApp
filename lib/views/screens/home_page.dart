import 'dart:async';
import 'dart:convert';
import 'package:cart_app_viva/Provider/ThemeProvider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../helper/dbhelper.dart';
import '../../models/product_models.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<void> _initFuture;
  late Timer _stockOutTimer;
  late Timer _resetQuantityTimer;

  @override
  void initState() {
    super.initState();
    _initFuture = initAndFetchData();
  }

  @override
  void dispose() {
    _stockOutTimer.cancel();
    _resetQuantityTimer.cancel();
    super.dispose();
  }

  Future<void> initAndFetchData() async {
    await DBHelper.dbHelper.initDB();
    await DBHelper.dbHelper.loadString(path: "assets/json/product_data.json");
    await DBHelper.dbHelper.insertBulkRecord();
    await DBHelper.dbHelper.fetchData();
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    final DBHelper dbHelper = DBHelper.dbHelper;
    return (defaultTargetPlatform == TargetPlatform.android)
        ? WillPopScope(
            onWillPop: () async {
              return await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text("Are You Sure.."),
                  content: Text("Do you Want to Exit..."),
                  actions: [
                    ElevatedButton(
                        onPressed: () {
                          Get.back();
                          Future.delayed(Duration.zero, () {
                            Get.until((route) => route.isFirst);
                          });
                        },
                        child: Text("Yes")),
                    ElevatedButton(
                      onPressed: () {
                        Get.back();
                      },
                      child: Text("No"),
                    ),
                  ],
                ),
              );
            },
            child: Scaffold(
              drawer: Drawer(
                width: w * 0.8,
                child: Column(
                  children: [
                    SizedBox(
                      height: h * 0.1,
                    ),
                    CircleAvatar(
                      radius: 80,
                      foregroundImage: NetworkImage(
                          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRB6r2bCF56xUv4Tkqqmrj3XzCfsxjA-Ju6VmVVo-Y&s"),
                    ),
                    SizedBox(
                      height: h * 0.03,
                    ),
                    Text(
                      "IStore",
                      style: TextStyle(
                        fontSize: h * 0.025,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(
                        Icons.shopping_cart,
                      ),
                      title: Text("Cart Page"),
                      trailing: Icon(
                        Icons.arrow_forward_sharp,
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.mode_night),
                      title: Text("Change Theme"),
                      trailing: Switch(
                        value: Provider.of<ThemeProvider>(context).isDark,
                        onChanged: (val) {
                          Provider.of<ThemeProvider>(context, listen: false)
                              .ChangeAppTheme(val);
                        },
                      ),
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.shopping_cart,
                      ),
                      title: Text("Setting"),
                      trailing: Icon(
                        Icons.arrow_forward_sharp,
                      ),
                    ),
                    Divider(),
                  ],
                ),
              ),
              appBar: AppBar(
                actions: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.refresh,
                    ),
                  ),
                ],
                title: Text(
                  "Welcome To IStore",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: Get.height * 0.022,
                  ),
                ),
                centerTitle: true,
              ),
              body: FutureBuilder(
                future: _initFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'No Data Found',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: h * 0.025,
                        ),
                      ),
                    );
                  } else {
                    return Padding(
                      padding: EdgeInsets.only(
                        left: Get.width * 0.05,
                        right: Get.width * 0.05,
                        top: Get.height * 0.03,
                      ),
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          mainAxisExtent: 350,
                        ),
                        itemCount: dbHelper.productList.length,
                        itemBuilder: (context, index) {
                          Product product = dbHelper.productList[index];
                          return Column(
                            children: [
                              Column(
                                children: [
                                  Container(
                                    height: Get.height * 0.2,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: MemoryImage(
                                          base64Decode(product.image!),
                                        ),
                                        fit: BoxFit.fitHeight,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: h * 0.01,
                                  ),
                                  (index == dbHelper.randomNumber)
                                      ? Text(
                                          "Stock Out in ${dbHelper.countDown}s",
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w700,
                                            fontSize: Get.width * 0.04,
                                          ),
                                        )
                                      : Text(
                                          "Stock : ${product.quantity}",
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w700,
                                            fontSize: Get.width * 0.04,
                                          ),
                                        ),
                                  SizedBox(
                                    height: h * 0.01,
                                  ),
                                  Text(
                                    "${product.name}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: h * 0.02,
                                    ),
                                  ),
                                  SizedBox(
                                    height: h * 0.01,
                                  ),
                                  Container(
                                    height: h * 0.05,
                                    width: w,
                                    decoration: BoxDecoration(
                                      color: Colors.grey,
                                      borderRadius: BorderRadius.circular(
                                        h * 0.02,
                                      ),
                                    ),
                                    child: Center(
                                      child: (index == dbHelper.randomNumber)
                                          ? Text(
                                              "No Stock Available",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: h * 0.02,
                                              ),
                                            )
                                          : Text(
                                              "ADD TO CART",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: h * 0.02,
                                              ),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    );
                  }
                },
              ),
            ),
          )
        : CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              middle: Text(
                "Welcome To IStore",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: h * 0.022,
                ),
              ),
              trailing: CupertinoButton(
                onPressed: () {},
                child: Icon(
                  CupertinoIcons.refresh,
                ),
              ),
              transitionBetweenRoutes: false,
            ),
            child: FutureBuilder(
              future: _initFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CupertinoActivityIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'No Data Found',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: h * 0.025,
                      ),
                    ),
                  );
                } else {
                  return Padding(
                    padding: EdgeInsets.only(
                      left: w * 0.05,
                      right: w * 0.05,
                      top: h * 0.03,
                    ),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        mainAxisExtent: 350,
                      ),
                      itemCount: dbHelper.productList.length,
                      itemBuilder: (context, index) {
                        Product product = dbHelper.productList[index];
                        return Column(
                          children: [
                            Column(
                              children: [
                                Container(
                                  height: h * 0.2,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: MemoryImage(
                                        base64Decode(product.image!),
                                      ),
                                      fit: BoxFit.fitHeight,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: h * 0.01,
                                ),
                                (index == dbHelper.randomNumber)
                                    ? Text(
                                        "Stock Out in ${dbHelper.countDown}s",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: w * 0.04,
                                        ),
                                      )
                                    : Text(
                                        "Stock : ${product.quantity}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: w * 0.04,
                                        ),
                                      ),
                                SizedBox(
                                  height: h * 0.01,
                                ),
                                Text(
                                  "${product.name}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: h * 0.02,
                                  ),
                                ),
                                SizedBox(
                                  height: h * 0.01,
                                ),
                                Container(
                                  height: h * 0.05,
                                  width: w,
                                  decoration: BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.circular(
                                      h * 0.02,
                                    ),
                                  ),
                                  child: Center(
                                    child: (index == dbHelper.randomNumber)
                                        ? Text(
                                            "No Stock Available",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: h * 0.02,
                                            ),
                                          )
                                        : Text(
                                            "ADD TO CART",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: h * 0.02,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  );
                }
              },
            ),
            // Drawer can be implemented using CupertinoPageScaffold too
            // Add a gesture to open the drawer if needed
            // drawer: CupertinoDrawer(),
          );
  }
}
