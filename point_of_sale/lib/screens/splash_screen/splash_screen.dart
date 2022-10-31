import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:marketsystem/controllers/auth_controller.dart';
import 'package:marketsystem/controllers/printManagementController.dart';
import 'package:marketsystem/controllers/products_controller.dart';
import 'package:marketsystem/layout/market_layout.dart';
import 'package:marketsystem/shared/constant.dart';
import 'package:marketsystem/shared/local/marketdb_helper.dart';
import 'package:marketsystem/shared/styles.dart';
// ignore: unused_import
import 'package:marketsystem/shared/toast_message.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // ignore: todo
    // TODO: implement initState
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _connectPrinter_IfAvailable();
      _load_products().then((value) {
        print('getting products');
      });
    });
  }

  Future _load_products() async {
    Future.delayed(Duration(seconds: 2)).then((value) async {
      await _loadUserData();
      await MarketDbHelper.db.init().then((isdatabaseexist) async {
        await getDatabasesPath().then((value) async {
          print(value + "/Market.db");
          databasepath = value + "/Market.db";
          if (isdatabaseexist == true)
            await Provider.of<ProductsController>(context, listen: false)
                .getAllProduct()
                .then((value) => Get.off(MarketLayout()));
        });
      });
    });
  }

  Future _connectPrinter_IfAvailable() async {
    if (device_mac != null) {
      await context
          .read<PrintManagementController>()
          .getBluetooth()
          .then((value) async {
        if (context
                .read<PrintManagementController>()
                .availableBluetoothDevices
                .length >
            0)
          // if device available conntect to saved mac address
          await context
              .read<PrintManagementController>()
              .setConnect(device_mac);
      });
    }
  }

  Future _loadUserData() async {
    await Provider.of<AuthController>(context, listen: false)
        .getUserData()
        .then((value) {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MarketDbHelper>(
      create: (_) => MarketDbHelper.db,
      child: Container(
        decoration: BoxDecoration(gradient: myLinearGradient),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: const Image(
                        image: AssetImage("assets/splash_screen.png")),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Pos System",
                    style: TextStyle(
                        color: Colors.white, letterSpacing: 1, fontSize: 30),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Consumer<MarketDbHelper>(
                    builder: (BuildContext context, controller, Widget? child) {
                      if (controller.is_has_connection)
                        return SpinKitWave(
                          color: Colors.white,
                          size: 35.0,
                        );
                      else {
                        return Container(
                          color: Colors.redAccent,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              "check your network connection and try again",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Consumer<MarketDbHelper>(
                    builder: (BuildContext context, controller, Widget? child) {
                      if (controller.is_databaseExist == false)
                        return Text(
                          controller.progressDownload.toString(),
                          style: TextStyle(
                              color: Colors.white,
                              letterSpacing: 1,
                              fontSize: 20),
                        );
                      return Container();
                    },
                  ),
                ],
              )),
        ),
      ),
    );
  }
}
