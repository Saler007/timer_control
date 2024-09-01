import 'dart:io';
import 'package:flutter/cupertino.dart';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:timer_control/bluetooth/snack_bar.dart';
// import 'package:location/location.dart';

Future checkBluetoothDevice(BuildContext context, VoidCallback scanResult) async {
  // Location location = new Location();
  if (await FlutterBluePlus.isSupported == true) {
    try {
      if (Platform.isAndroid) {
        await FlutterBluePlus.turnOn();
        var subscription = FlutterBluePlus.adapterState.listen((
            BluetoothAdapterState state) async {
          if (state == BluetoothAdapterState.on) {}
        });
        subscription.cancel(); // cancel to prevent duplicate listeners
        // access to user location for android 10 only
        // var accessLocation = await location.hasPermission();
        // if (accessLocation.toString() == "PermissionStatus.granted") {
        //   var turnOnLocation = await location.requestService();
        //   if (turnOnLocation == true) {
        //     scanResult();
        //     debugPrint('Location is turned on');
        //   } else {
        //     debugPrint('Location is not turned on');
        //   }
        // } else {
        //   scanResult();
        //   debugPrint('Location: ${accessLocation.toString()}');
        // }
      }
    } catch (e) {
      ASnackBar.show(
          ABC.a, prettyException("Error Turning On:", e), success: false);
    }
  } else {
    debugPrint("Bluetooth not supported by this device");
    return;
  }
}