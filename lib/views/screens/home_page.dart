import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
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
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.menu),
        actions: [
          IconButton(
              onPressed: () {}, icon: const Icon(Icons.shopping_cart_outlined)),
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
            return ProductListView();
          }
        },
      ),
    );
  }
}

class ProductListView extends StatefulWidget {
  ProductListView({super.key});

  @override
  State<ProductListView> createState() => _ProductListViewState();
}

class _ProductListViewState extends State<ProductListView> {
  final DBHelper dbHelper = DBHelper.dbHelper;

  @override
  Widget build(BuildContext context) {
    double h = Get.height;
    double w = Get.width;
    return Padding(
      padding: EdgeInsets.only(
        left: Get.width * 0.05,
        right: Get.width * 0.05,
        top: Get.height * 0.03,
      ),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                            fontSize: Get.width * 0.04,
                          ),
                        )
                      : Text("Stock : ${product.quantity}"),
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
}
