import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:intl/intl.dart';
import 'package:timer_control/bluetooth/controller/scan_result_tile.dart';
import 'package:timer_control/bluetooth/controller/system_device_tile.dart';
import 'package:timer_control/bluetooth/device_info_screen.dart';
import 'package:timer_control/bluetooth/extra.dart';
import 'package:timer_control/bluetooth/pop_up_message.dart';
import 'package:timer_control/bluetooth/snack_bar.dart';
import 'package:timer_control/size_config.dart';
import 'package:timer_control/spaces.dart';
import 'package:timer_control/typographies.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  List<ScanResult> _scanResults = [];
  List<BluetoothService> _services = [];
  List<BluetoothDevice> _systemDevices = [];
  BluetoothCharacteristic? _characteristic;
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;
  BluetoothConnectionState _connectionState =
      BluetoothConnectionState.disconnected;

  @override
  void initState() {
    super.initState();
    _loadingController =
        AnimationController(duration: const Duration(seconds: 2), vsync: this)
          ..repeat(); // Repeat the animation
    _setupBluetoothSubscriptions();
  }

  late AnimationController _loadingController;
  late StreamSubscription<bool> _isScanningSubscription;
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
  late StreamSubscription<BluetoothAdapterState> _adapterStateStateSubscription;
  late StreamSubscription<BluetoothConnectionState>
      _connectionStateSubscription;

  @override
  void dispose() {
    _loadingController.dispose();
    _isScanningSubscription.cancel();
    _scanResultsSubscription.cancel();
    _adapterStateStateSubscription.cancel();
    FlutterBluePlus.stopScan(); // Stop scanning when disposing
    super.dispose();
  }

  final String _title = 'Clock Control';

  bool _isScanning = false;
  bool get isConnected =>
      _connectionState == BluetoothConnectionState.connected;
  bool _isStart = false;

  List<String> dayInWeek = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  List<bool> isSelected = List.filled(7, false);

  TimeOfDay selectedTime = TimeOfDay.now();
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(247, 247, 247, 1),
      appBar: AppBar(
        backgroundColor: Colors.green,
        centerTitle: true,
        title: Text(
          _title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              _onScanPressed();
              scanBluetooth();
              // checkBluetoothDevice(context, scanBluetooth());
            },
            child: Icon(
              isConnected? CupertinoIcons.arrow_up_arrow_down_circle_fill:CupertinoIcons.arrow_up_arrow_down,
              color: isConnected? Colors.yellow:Colors.white,
              size: 32,
            ),
          ),
          horizontalSpacing(16),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: widthConfig(16)),
        child: Column(children: [
          verticalSpacing(64),
          CupertinoButton(
            onPressed: () async {
              final TimeOfDay? timeOfDay = await showTimePicker(
                context: context,
                initialTime: selectedTime,
                initialEntryMode: TimePickerEntryMode.dial,
              );
              if (timeOfDay != null) {
                setState(() {
                  selectedTime = timeOfDay;
                });
              }
            },
            child:
            Container(
              height: heightConfig(200),
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(
                horizontal: widthConfig(16),
                vertical: heightConfig(16),
              ),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(52, 199, 89, 0.6),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.green, width: 1),
              ),
              child: Text(
                '${selectedTime.hour}:${selectedTime.minute}',
                style: regularFontSize(52, Colors.white),
              ),
            ),
          ),
          Text(
            '${DateFormat('EEEE').format(selectedDate)}/${selectedDate.month}/${selectedDate.year}',
            style: regularFontSize(20, Colors.black),
          ),
          verticalSpacing(64),

          Container(
            height: 1,
            color: const Color.fromRGBO(216, 216, 216, 1),
          ),
          verticalSpacing(16),
          Container(
              alignment: Alignment.centerLeft,
              child: Text('Repeat', style: boldFontSize(16, Colors.black))),
          verticalSpacing(16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    isSelected[0] = !isSelected[0];
                  });
                },
                child: Container(
                  height: heightConfig(48),
                  width: widthConfig(48),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected[0] ? Colors.blue : null,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: isSelected[0] ? Colors.white : Colors.green,
                        width: 0.5),
                  ),
                  child: Text(dayInWeek[0],
                      style: regularFontSize(
                          18, isSelected[0] ? Colors.white : Colors.green)),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isSelected[1] = !isSelected[1];
                  });
                },
                child: Container(
                  height: heightConfig(48),
                  width: widthConfig(48),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected[1] ? Colors.blue : null,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: isSelected[1] ? Colors.white : Colors.green,
                        width: 0.5),
                  ),
                  child: Text(dayInWeek[1],
                      style: regularFontSize(
                          18, isSelected[1] ? Colors.white : Colors.green)),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isSelected[2] = !isSelected[2];
                  });
                },
                child: Container(
                  height: heightConfig(48),
                  width: widthConfig(48),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected[2] ? Colors.blue : null,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: isSelected[2] ? Colors.white : Colors.green,
                        width: 0.5),
                  ),
                  child: Text(dayInWeek[2],
                      style: regularFontSize(
                          18, isSelected[2] ? Colors.white : Colors.green)),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isSelected[3] = !isSelected[3];
                  });
                },
                child: Container(
                  height: heightConfig(48),
                  width: widthConfig(48),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected[3] ? Colors.blue : null,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: isSelected[3] ? Colors.white : Colors.green,
                        width: 0.5),
                  ),
                  child: Text(dayInWeek[3],
                      style: regularFontSize(
                          18, isSelected[3] ? Colors.white : Colors.green)),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isSelected[4] = !isSelected[4];
                  });
                },
                child: Container(
                  height: heightConfig(48),
                  width: widthConfig(48),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected[4] ? Colors.blue : null,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: isSelected[4] ? Colors.white : Colors.green,
                        width: 0.5),
                  ),
                  child: Text(dayInWeek[4],
                      style: regularFontSize(
                          18, isSelected[4] ? Colors.white : Colors.green)),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isSelected[5] = !isSelected[5];
                  });
                },
                child: Container(
                  height: heightConfig(48),
                  width: widthConfig(48),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected[5] ? Colors.blue : null,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: isSelected[5] ? Colors.white : Colors.green,
                        width: 0.5),
                  ),
                  child: Text(dayInWeek[5],
                      style: regularFontSize(
                          18, isSelected[5] ? Colors.white : Colors.green)),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isSelected[6] = !isSelected[6];
                  });
                },
                child: Container(
                  height: heightConfig(48),
                  width: widthConfig(48),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected[6] ? Colors.blue : null,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: isSelected[6] ? Colors.white : Colors.green,
                        width: 0.5),
                  ),
                  child: Text(dayInWeek[6],
                      style: regularFontSize(
                          18, isSelected[6] ? Colors.white : Colors.green)),
                ),
              ),
            ],
          ),
          verticalSpacing(24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Every ${dayInWeek.join(', ')}',
                  style: regularFontSize(16, Colors.black),
                ),
              ),
              IconButton(
                  onPressed: () async {
                    final DateTime? dateTime = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2024),
                      lastDate: DateTime(2025),
                    );
                    if (dateTime != null) {
                      setState(() {
                        selectedDate = dateTime;
                      });
                    }
                  },
                  icon: Icon(Icons.calendar_month)),
            ],
          ),
          verticalSpacing(32),
          const Spacer(),
          Expanded(child: _buildRunButton()),
          // verticalSpacing(32),
        ]),
      ),
    );
  }

  // Run button
  Widget _buildRunButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 2,
          child: CupertinoButton(
            minSize: heightConfig(48),
            padding: EdgeInsets.zero,
            onPressed: () async {
              if (isConnected == true) {
                setState(() {
                  _isStart = false;
                });
                try {
                  List<int> dataBytes = utf8.encode('stop');
                  await _characteristic!.write(dataBytes);
                } catch (error) {
                  debugPrint('Error :$error');
                }

              } else {
                await popUpConnectMessage(context, 'Please connect to device');
              }
            },
            child: Container(
              height: heightConfig(48),
              color: _isStart ? Colors.red : const Color.fromRGBO(0, 0, 0, 0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Stop',
                      style: boldFontSize(
                          16, _isStart ? Colors.white : Colors.grey)),
                ],
              ),
            ),
          ),
        ),
        horizontalSpacing(16),
        Expanded(
          flex: 3,
          child: CupertinoButton(
            minSize: heightConfig(48),
            padding: EdgeInsets.zero,
            onPressed: () async {
              if (isConnected == true) {
                setState(() {
                  _isStart = true;
                });
                try {
                  List<int> dataBytes = utf8.encode('start');
                  await _characteristic!.write(dataBytes);
                } catch (error) {
                  debugPrint('Error :$error');
                }
              } else {
                await popUpConnectMessage(context, 'Please connect to device');
              }
            },
            child: Container(
              height: heightConfig(48),
              decoration: BoxDecoration(
                color: !_isStart
                    ? const Color.fromRGBO(52, 199, 89, 1)
                    : const Color.fromRGBO(52, 199, 89, 0.5),
                borderRadius: BorderRadius.circular(4),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(52, 199, 89, 1),
                    offset: Offset(0, 0.5),
                    spreadRadius: -2,
                    blurRadius: 1.5,
                    blurStyle: BlurStyle.outer,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Start', style: boldFontSize(16, Colors.white)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // show scan bluetooth result
  Future scanBluetooth() => showDialog(
      context: context,
      barrierColor: const Color.fromRGBO(0, 0, 0, 0.05),
      barrierDismissible: true,
      builder: (context) {
        return ScaffoldMessenger(
          key: ASnackBar.snackBarKeyB,
          child: Container(
            margin: EdgeInsets.only(
              top: heightConfig(156),
              bottom: heightConfig(156),
              left: widthConfig(44),
              right: widthConfig(44),
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: const [
                        BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.15), blurRadius: 4)
                      ]),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Column(children: [
                      Container(
                        height: ScreenSize.isPortrait
                            ? heightConfig(56)
                            : heightConfig(72),
                        padding: EdgeInsets.only(left: widthConfig(16)),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                                blurRadius: 1,
                                color: Color.fromRGBO(0, 0, 0, 0.25))
                          ],
                        ),
                        child: Row(
                          children: [
                            Text('Devices',
                                style: boldFontSize(16, Colors.black)),
                            const Spacer(),
                            CupertinoButton(
                              minSize: widthConfig(24),
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                FlutterBluePlus
                                    .stopScan(); // Stop scanning when disposing
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                height: heightConfig(24),
                                width: widthConfig(24),
                                alignment: Alignment.centerRight,
                                child: const Icon(Icons.backspace_outlined),
                              ),
                            ),
                            horizontalSpacing(16),
                          ],
                        ),
                      ),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: onRefresh,
                          child: CupertinoScrollbar(
                            thumbVisibility: true,
                            thickness: 3,
                            radius: const Radius.circular(4),
                            child: ListView(
                              children: [
                                _buildSystemDeviceTiles(context),
                                _buildScanResultTiles(context),
                                verticalSpacing(16),
                                _buildScanningText(context),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
            ),
          ),
        );
      });

  void _setupBluetoothSubscriptions() {
    _adapterStateStateSubscription =
        FlutterBluePlus.adapterState.listen((state) async {
      _adapterState = state;
      if (_adapterState == BluetoothAdapterState.off) {
        if (Platform.isAndroid) {
          await FlutterBluePlus.turnOn();
        }
      }
      if (mounted) {
        setState(() {});
      }
    });

    _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
      _scanResults = results;
      if (_systemDevices.isNotEmpty) {
        _scanResults.clear();
      }
      FlutterBluePlus.cancelWhenScanComplete(_scanResultsSubscription);
      if (mounted) {
        setState(() {});
      }
    }, onError: (e) {
      debugPrint('Scan Error: $e');
    });

    _isScanningSubscription = FlutterBluePlus.isScanning.listen((state) {
      _isScanning = state;
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future _onScanPressed() async {
    _systemDevices = await FlutterBluePlus.systemDevices;
    if (_systemDevices.isNotEmpty) {
      _connectionStateSubscription =
          _systemDevices[0].connectionState.listen((state) async {
        _connectionState = state;
        if (state == BluetoothConnectionState.connected) {
          onDiscoverServices();
        } else if (mounted) {
          setState(() {});
        }
      });
    }
    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));
    } catch (e) {
      debugPrint('Start Scan Error: $e');
    }
    if (mounted) {
      setState(() {});
    }
  }

  Future onStopPressed() async {
    try {
      FlutterBluePlus.stopScan();
    } catch (e) {
      debugPrint('Stop Scan Error: $e');
    }
  }

  Future onRefresh() {
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 3));
    if (mounted) {
      setState(() {});
    }
    return Future.delayed(const Duration(milliseconds: 500));
  }

  void onConnectPressed(BluetoothDevice device) {
    popUpCircleLoading(context, _loadingController);
    device
        .connectAndUpdateStream()
        .catchError((e) => ASnackBar.show(
            ABC.b, prettyException("Unable to connect:", e),
            success: false))
        .then((value) => _onScanPressed())
        .then((value) => Navigator.of(context).pop());
  }

  void onDisconnectPressed(BluetoothDevice device) {
    popUpDisconnectMessage(
      context,
      device,
      onPressed: () {
        try {
          device
              .disconnectAndUpdateStream()
              .then((value) => setState(() => _systemDevices.clear()))
              .then((value) => _onScanPressed())
              .then((value) => Navigator.of(context).pop());
          debugPrint('System devices: $_systemDevices');
          ASnackBar.show(ABC.c, "Disconnect: Success", success: true);
        } catch (e) {
          ASnackBar.show(ABC.c, prettyException("Disconnect Error:", e),
              success: false);
        }
      },
    );
  }

  Future onDiscoverServices() async {
    try {
      _services = await _systemDevices[0].discoverServices();
      _services.forEach((service) async {
        var characteristics = service.characteristics;
        for (BluetoothCharacteristic c in characteristics) {
          if (c.properties.write) {
            _characteristic = c;
            break;
          }
          if (c.properties.read) {
            List<int> value = await c.read();
            debugPrint('$value');
          }
        }
      });
      ASnackBar.show(ABC.b, "Connection: Success", success: true);
    } catch (e) {
      ASnackBar.show(ABC.b, prettyException("Connection:", e), success: false);
    }
    if (mounted) {
      setState(() {});
    }
  }

  // stream system device
  Widget _buildSystemDeviceTiles(BuildContext context) {
    return StreamBuilder<List<BluetoothDevice>>(
      stream: Stream.periodic(const Duration(milliseconds: 500)).asyncMap(
        (dynamic) => FlutterBluePlus.systemDevices,
      ),
      initialData: _systemDevices,
      builder: (context, snapshot) => Column(
        children: _systemDevices
            .map(
              (d) => SystemDeviceTile(
                device: d,
                onOpen: () => Navigator.of(context).push(CupertinoPageRoute(
                    builder: (context) => DeviceInfoScreen(device: d))),
                onDisconnect: () => onDisconnectPressed(d),
              ),
            )
            .toList(),
      ),
    );
  }

  // stream scan result
  Widget _buildScanResultTiles(BuildContext context) {
    return StreamBuilder<List<ScanResult>>(
      stream: FlutterBluePlus.scanResults,
      initialData: const [],
      builder: (context, snapshot) => Column(
        children: [
          Column(
            children: _scanResults
                .map(
                  (r) => ScanResultTile(
                    result: r,
                    onTap: () => onConnectPressed(r.device),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  // stream scanning text
  Widget _buildScanningText(BuildContext context) {
    return StreamBuilder<bool>(
      stream: FlutterBluePlus.isScanning,
      initialData: false,
      builder: (context, snapshot) => _systemDevices.isNotEmpty
          ? Container()
          : Text(
              _isScanning
                  ? 'Searching...'
                  : _scanResults.isNotEmpty
                      ? ''
                      : 'No devices were found!',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
    );
  }
}

class WeekDayToggle extends StatelessWidget {
  final void Function(bool) onToggle;
  final bool current;
  final String text;

  const WeekDayToggle(
      {Key? key,
      required this.onToggle,
      required this.current,
      required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    const size = 20.0;
    final textColor = this.current ? Colors.white : Colors.deepPurple;
    final blobColor = this.current ? Colors.deepPurple : Colors.white;

    return GestureDetector(
      child: SizedBox.fromSize(
        size: Size.fromRadius(size),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: new BorderRadius.circular(size), color: blobColor),
          child: Center(
              child: Text(
            this.text,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          )),
        ),
      ),
      onTap: () => this.onToggle(!this.current),
    );
  }
}
