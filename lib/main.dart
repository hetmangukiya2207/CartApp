import 'package:cart_app_viva/Provider/ThemeProvider.dart';
import 'package:cart_app_viva/views/screens/SplashScreen.dart';
import 'package:cart_app_viva/views/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider(create: (context) => ThemeProvider(),),
    ],
      builder:(context, child) =>  GetMaterialApp(

        themeMode:
        (Provider.of<ThemeProvider>(context).isDark == true)
            ? ThemeMode.dark
            : ThemeMode.light,
        theme: ThemeData.light(
          useMaterial3: true,
        ),
        darkTheme: ThemeData.dark(
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: 'SplashScreen',
        routes: {
          '/': (context) => const HomePage(),
          'SplashScreen': (context) => const SplashScreen(),
        },
      ),
    );
  }
}
