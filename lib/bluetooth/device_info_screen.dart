import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:timer_control/bluetooth/controller/characteristic_tile.dart';
import 'package:timer_control/bluetooth/controller/descriptor_tile.dart';
import 'package:timer_control/bluetooth/controller/service_tile.dart';
import 'package:timer_control/bluetooth/extra.dart';
import 'package:timer_control/bluetooth/pop_up_message.dart';
import 'package:timer_control/bluetooth/snack_bar.dart';

class DeviceInfoScreen extends StatefulWidget {
  final BluetoothDevice device;
  const DeviceInfoScreen({super.key, required this.device});

  @override
  State<DeviceInfoScreen> createState() => _DeviceInfoScreenState();
}

class _DeviceInfoScreenState extends State<DeviceInfoScreen> {
  BluetoothConnectionState _connectionState =
      BluetoothConnectionState.disconnected;
  List<BluetoothService> _services = [];
  List<String> infoText = ['Remote ID: ', 'Get Services', 'MTU Size: '];
  int? _rssi;
  int? _mtuSize;
  bool _isConnecting = false;
  bool _isDisconnecting = false;
  bool _isDiscoveringServices = false;

  late StreamSubscription<int> _mtuSubscription;
  late StreamSubscription<bool> _isConnectingSubscription;
  late StreamSubscription<bool> _isDisconnectingSubscription;
  late StreamSubscription<BluetoothConnectionState>
      _connectionStateSubscription;

  void streamSubscription() {
    _connectionStateSubscription =
        widget.device.connectionState.listen((state) async {
      _connectionState = state;
      if (state == BluetoothConnectionState.connected) {
        _services = []; // must rediscover services
      }
      if (state == BluetoothConnectionState.connected && _rssi == null) {
        _rssi = await widget.device.readRssi();
      }
      if (mounted) {
        setState(() {});
      }
    });

    _mtuSubscription = widget.device.mtu.listen((value) {
      _mtuSize = value;
      if (mounted) {
        setState(() {});
      }
    });

    _isConnectingSubscription = widget.device.isConnecting.listen((value) {
      _isConnecting = value;
      if (mounted) {
        setState(() {});
      }
    });

    _isDisconnectingSubscription =
        widget.device.isDisconnecting.listen((value) {
      _isDisconnecting = value;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void initState() {
    super.initState();
    streamSubscription();
  }

  @override
  void dispose() {
    _mtuSubscription.cancel();
    _isConnectingSubscription.cancel();
    _connectionStateSubscription.cancel();
    _isDisconnectingSubscription.cancel();
    super.dispose();
  }

  // remote id
  Widget _buildRemoteId(BuildContext context) {
    return Container(
      height: 50,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(width: 0.5, color: Colors.grey)),
      ),
      child: Text(
        '${infoText[0]}${widget.device.remoteId}',
        style: const TextStyle(fontSize: 16, color: Colors.black),
      ),
    );
  }

  // rssi
  Widget _buildRssiTile(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        isConnected
            ? const Icon(Icons.bluetooth, color: Colors.blue)
            : const Icon(Icons.bluetooth_disabled),
        Text(
          ((isConnected && _rssi != null) ? '${_rssi!} dBm' : ''),
          style: const TextStyle(fontSize: 16, color: Colors.black),
        ),
      ],
    );
  }

  // get services
  Widget _buildGetServices(BuildContext context) {
    return IndexedStack(
      index: (_isDiscoveringServices) ? 1 : 0,
      alignment: Alignment.center,
      children: <Widget>[
        CupertinoButton(
          minSize: 18,
          padding: EdgeInsets.zero,
          onPressed: onDiscoverServicesPressed,
          child: Text(
            infoText[1],
            style: const TextStyle(fontSize: 14, color: Colors.black),
          ),
        ),
        const IconButton(
          onPressed: null,
          icon: SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.grey),
            ),
          ),
        ),
      ],
    );
  }

  // mtu
  Widget _buildMtuTile(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(
            width: 0.5,
            color: Colors.grey,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
                text: infoText[2],
                style: const TextStyle(fontSize: 14, color: Colors.black),
                children: [
                  TextSpan(
                    text: '$_mtuSize bytes',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ]),
          ),
          const Spacer(),
          CupertinoButton(
            minSize: 24,
            padding: EdgeInsets.zero,
            onPressed: onRequestMtuPressed,
            child: const Icon(Icons.swap_horiz_sharp, size: 24),
          ),
        ],
      ),
    );
  }

  // connection button
  Widget _buildConnectButton(BuildContext context) {
    return CupertinoButton(
      onPressed: _isConnecting
          ? onCancelPressed
          : (isConnected ? onDisconnectPressed : onConnectPressed),
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          _isConnecting ? "Cancel" : (isConnected ? "Disconnect" : "Connect"),
          style: const TextStyle(fontSize: 16, color: Colors.red),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: ScaffoldMessenger(
        key: ASnackBar.snackBarKeyC,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            elevation: 2,
            backgroundColor: Colors.green,
            centerTitle: true,
            title: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                widget.device.platformName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            actions: [
              _buildConnectButton(context),
              const SizedBox(width: 16),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 16),
                Container(
                  height: 600,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(width: 0.5, color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildRemoteId(context),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 16,
                            ),
                            child: Row(
                              children: [
                                _buildRssiTile(context),
                                const Spacer(),
                                _buildGetServices(context),
                              ],
                            ),
                          ),
                        ],
                      ),
                      _buildMtuTile(context),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: _buildServiceTiles(
                              context,
                              widget.device,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 160),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool get isConnected {
    return _connectionState == BluetoothConnectionState.connected;
  }

  List<Widget> _buildServiceTiles(BuildContext context, BluetoothDevice d) {
    return _services
        .map(
          (s) => ServiceTile(
            service: s,
            characteristicTiles: s.characteristics
                .map((c) => _buildCharacteristicTile(c))
                .toList(),
          ),
        )
        .toList();
  }

  CharacteristicTile _buildCharacteristicTile(BluetoothCharacteristic c) {
    return CharacteristicTile(
      characteristic: c,
      descriptorTiles:
          c.descriptors.map((d) => DescriptorTile(descriptor: d)).toList(),
    );
  }

  Future onConnectPressed() async {
    try {
      await widget.device.connectAndUpdateStream();
      ASnackBar.show(ABC.c, "Connect: Success", success: true);
    } catch (e) {
      if (e is FlutterBluePlusException &&
          e.code == FbpErrorCode.connectionCanceled.index) {
        // ignore connections canceled by the user
      } else {
        ASnackBar.show(ABC.c, prettyException("Connect Error:", e),
            success: false);
      }
    }
  }

  Future onCancelPressed() async {
    try {
      await widget.device.disconnectAndUpdateStream(queue: false);
      ASnackBar.show(ABC.c, "Cancel: Success", success: true);
    } catch (e) {
      ASnackBar.show(ABC.c, prettyException("Cancel Error:", e),
          success: false);
    }
  }

  Future onDisconnectPressed() async {
    try {
      // await widget.device.disconnectAndUpdateStream();
      popUpDisconnectMessage(
        context,
        widget.device,
        onPressed: () {},
      );
      ASnackBar.show(ABC.c, "Disconnect: Success", success: true);
    } catch (e) {
      ASnackBar.show(ABC.c, prettyException("Disconnect Error:", e),
          success: false);
    }
  }

  Future onDiscoverServicesPressed() async {
    if (mounted) {
      setState(() {
        _isDiscoveringServices = true;
      });
    }
    try {
      _services = await widget.device.discoverServices();
      ASnackBar.show(ABC.c, "Discover Services: Success", success: true);
    } catch (e) {
      ASnackBar.show(ABC.c, prettyException("Discover Services Error:", e),
          success: false);
    }
    if (mounted) {
      setState(() {
        _isDiscoveringServices = false;
      });
    }
  }

  Future onRequestMtuPressed() async {
    try {
      await widget.device.requestMtu(223, predelay: 0);
      ASnackBar.show(ABC.c, "Request Mtu: Success", success: true);
    } catch (e) {
      ASnackBar.show(ABC.c, prettyException("Change Mtu Error:", e),
          success: false);
    }
  }
}
