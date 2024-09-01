// import 'dart:async';
//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// import 'controller/scan_result_tile.dart';
// import 'controller/system_device_tile.dart';
// import 'device_info_screen.dart';
// import 'snack_bar.dart';
//
// class ScanScreen extends StatefulWidget {
//   const ScanScreen({super.key});
//
//   @override
//   State<ScanScreen> createState() => _ScanScreenState();
// }
//
// class _ScanScreenState extends State<ScanScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _loadingController;
//   late StreamSubscription<bool> _isScanningSubscription;
//   late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
//   late StreamSubscription<BluetoothAdapterState> _isAdapterOnSubscription;
//   List<BluetoothDevice> _systemDevices = [];
//   List<ScanResult> _scanResults = [];
//   bool _isScanning = false;
//   String text = 'Searching...';
//
//   @override
//   void initState() {
//     super.initState();
//     _loadingController =
//         AnimationController(duration: const Duration(seconds: 2), vsync: this)
//           ..repeat(); // Repeat the animation
//     _setupBluetoothSubscriptions();
//     onScanPressed();
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//     _loadingController.dispose();
//     _isScanningSubscription.cancel();
//     _isAdapterOnSubscription.cancel();
//     _scanResultsSubscription.cancel();
//     FlutterBluePlus.stopScan(); // Stop scanning when disposing
//   }
//
//   // stream system device
//   Widget _buildSystemDeviceTiles(BuildContext context) {
//     return StreamBuilder<List<BluetoothDevice>>(
//       stream: Stream.periodic(const Duration(milliseconds: 500)).asyncMap(
//         (dynamic) => FlutterBluePlus.systemDevices,
//       ),
//       initialData: _systemDevices,
//       builder: (context, snapshot) => Column(
//         children: _systemDevices
//             .map(
//               (d) => SystemDeviceTile(
//                 device: d,
//                 onOpen: () => Navigator.of(context).push(CupertinoPageRoute(
//                     builder: (context) => DeviceInfoScreen(device: d))),
//                 onDisconnect: () => onDisconnectPressed(d),
//               ),
//             )
//             .toList(),
//       ),
//     );
//   }
//
//   // stream scan result
//   Widget _buildScanResultTiles(BuildContext context) {
//     return StreamBuilder<List<ScanResult>>(
//       stream: FlutterBluePlus.scanResults,
//       initialData: const [],
//       builder: (context, snapshot) => Column(
//         children: [
//           Column(
//             children: _scanResults
//                 .map((r) => ScanResultTile(
//                       result: r,
//                       onTap: () => onConnectPressed(r.device),
//                     ))
//                 .toList(),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // stream scanning text
//   Widget _buildScanningText(BuildContext context) {
//     return StreamBuilder<bool>(
//       stream: FlutterBluePlus.isScanning,
//       initialData: false,
//       builder: (context, snapshot) => _systemDevices.isNotEmpty
//           ? Container()
//           : Text(
//               _isScanning
//                   ? 'Searching...'
//                   : _scanResults.isNotEmpty
//                       ? ''
//                       : 'No devices were found!',
//               style: const TextStyle(fontSize: 16, color: Colors.grey),
//             ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return ScaffoldMessenger(
//       key: ASnackBar.snackBarKeyB,
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         body: OrientationBuilder(
//           builder: (context, orientation) {
//             if (orientation == Orientation.portrait) {
//               return Column(
//                 children: [
//                   _buildHeader(context),
//                   const SizedBox(height: 16),
//                   Container(
//                     height: 600,
//                     width: double.infinity,
//                     margin: const EdgeInsets.symmetric(horizontal: 16),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(4),
//                       border: Border.all(width: 0.5, color: Colors.grey),
//                     ),
//                     child: RefreshIndicator(
//                       onRefresh: onRefresh,
//                       child: SingleChildScrollView(
//                         physics: const AlwaysScrollableScrollPhysics(),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             _buildSystemDeviceTiles(context),
//                             _buildScanResultTiles(context),
//                             const SizedBox(height: 16),
//                             Container(
//                               alignment: Alignment.centerLeft,
//                               padding: const EdgeInsets.only(left: 16),
//                               child: _buildScanningText(context),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               );
//             }
//             return Column(
//               children: [
//                 _buildHeader(context),
//                 const SizedBox(height: 24),
//                 Container(
//                   height: 800,
//                   width: 800,
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     border: Border.all(width: 0.5, color: Colors.grey),
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                   child: RefreshIndicator(
//                     onRefresh: onRefresh,
//                     child: SingleChildScrollView(
//                       physics: const AlwaysScrollableScrollPhysics(),
//                       child: Column(
//                         children: [
//                           _buildSystemDeviceTiles(context),
//                           _buildScanResultTiles(context),
//                           const SizedBox(height: 16),
//                           Container(
//                             alignment: Alignment.centerLeft,
//                             padding: const EdgeInsets.only(left: 16),
//                             child: _buildScanningText(context),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
//
//   Widget _buildScanButton(BuildContext context) {
//     return CupertinoButton(
//       minSize: 33,
//       padding: EdgeInsets.zero,
//       onPressed: FlutterBluePlus.isScanningNow ? onStopPressed : onScanPressed,
//       child: _isScanning
//           ? RotationTransition(
//               turns: _loadingController,
//               child: Icon(Icons.refresh,
//                   color: Colors.black, size: 33),
//             )
//           : Icon(Icons.refresh, color: Colors.black, size: 33),
//     );
//   }
//
//   Future onScanPressed() async {
//     try {
//       _systemDevices = await FlutterBluePlus.systemDevices;
//     } catch (e) {
//       debugPrint('System Devices Error: $e');
//     }
//     try {
//       await FlutterBluePlus.startScan(timeout: const Duration(seconds: 3));
//     } catch (e) {
//       debugPrint('Start Scan Error: $e');
//     }
//     if (mounted) {
//       setState(() {});
//     }
//   }
//
//   Future onStopPressed() async {
//     try {
//       FlutterBluePlus.stopScan();
//       _scanResultsSubscription.pause();
//     } catch (e) {
//       debugPrint('Stop Scan Error $e');
//     }
//   }
//
//   Future onRefresh() {
//     if (_isScanning == false) {
//       FlutterBluePlus.startScan(timeout: const Duration(seconds: 3));
//     }
//     if (mounted) {
//       setState(() {});
//     }
//     return Future.delayed(const Duration(milliseconds: 500));
//   }
//
//   void onConnectPressed(BluetoothDevice device) async {
//     popUpCircleLoading(context, _loadingController);
//     device
//         .connectAndUpdateStream()
//         .catchError((e) => ASnackBar.show(
//             ABC.c, prettyException("Connect Error:", e),
//             success: false))
//         .then((value) => onScanPressed())
//         .then((value) => Navigator.of(context).pop());
//   }
//
//   void onDisconnectPressed(BluetoothDevice device) {
//     popUpDisconnectMessage(
//       context,
//       device,
//       onPressed: () {
//         try {
//           device
//               .disconnectAndUpdateStream()
//               .then((value) => setState(() => _systemDevices.clear()))
//               .then((value) => onScanPressed())
//               .then((value) => Navigator.of(context).pop());
//           debugPrint('System devices: $_systemDevices');
//           ASnackBar.show(ABC.c, "Disconnect: Success", success: true);
//         } catch (e) {
//           ASnackBar.show(ABC.c, prettyException("Disconnect Error:", e),
//               success: false);
//         }
//       },
//     );
//   }
//
//   Widget _buildHeader(context) {
//     return Container(
//       decoration: ABoxDecoration.appBar,
//       child: AppBar(
//         backgroundColor: Colors.white,
//         leadingWidth:
//             ScreenSize.isPortrait ? widthConfig(100) : widthConfig(300),
//         leading: CupertinoButton(
//           minSize: heightConfig(22),
//           padding: EdgeInsets.zero,
//           onPressed: () => Navigator.of(context).pop(),
//           child: Container(
//             alignment: Alignment.centerLeft,
//             padding: EdgeInsets.only(
//                 top: heightConfig(8),
//                 left:
//                     ScreenSize.isPortrait ? widthConfig(16) : widthConfig(32)),
//             child: Image.asset(AIcons.back,
//                 height: ScreenSize.isPortrait
//                     ? heightConfig(22)
//                     : heightConfig(33)),
//           ),
//         ),
//         centerTitle: true,
//         title: Text(
//           'Find Devices',
//           style: ScreenSize.isPortrait
//               ? boldTitleFontSize(18, Colors.black)
//               : boldTitleFontSize(24, Colors.black),
//         ),
//         actions: <Widget>[
//           _buildScanButton(context),
//           ScreenSize.isPortrait ? horizontalSpacing(16) : horizontalSpacing(32),
//         ],
//       ),
//     );
//   }
//
//   void _setupBluetoothSubscriptions() {
//     _isAdapterOnSubscription = FlutterBluePlus.adapterState.listen(
//         (BluetoothAdapterState state) async {
//       if (state == BluetoothAdapterState.off) {
//         debugPrint('Bluetooth Adapter is off ');
//         await FlutterBluePlus.turnOn().then((value) {
//           FlutterBluePlus.startScan(timeout: const Duration(seconds: 3));
//         });
//       } else {
//         FlutterBluePlus.startScan(timeout: const Duration(seconds: 3));
//       }
//       if (mounted) {
//         setState(() {});
//       }
//     }, onError: (e) {
//       debugPrint('Bluetooth Adapter Error: $e');
//     });
//
//     _isScanningSubscription = FlutterBluePlus.isScanning.listen((state) async {
//       _isScanning = state;
//       if (mounted) {
//         setState(() {});
//       }
//     });
//
//     _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
//       _scanResults = results;
//       if (mounted) {
//         setState(() {});
//       }
//     }, onError: (e) {
//       debugPrint('Scan Error: $e');
//     });
//   }
// }
