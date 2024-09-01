import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:timer_control/typographies.dart';

class SystemDeviceTile extends StatefulWidget {
  final BluetoothDevice device;
  final VoidCallback onOpen;
  final VoidCallback onDisconnect;

  const SystemDeviceTile({
    required this.device,
    required this.onOpen,
    required this.onDisconnect,
    super.key,
  });

  @override
  State<SystemDeviceTile> createState() => _SystemDeviceTileState();
}

class _SystemDeviceTileState extends State<SystemDeviceTile> {
  BluetoothConnectionState _connectionState = BluetoothConnectionState.disconnected;
  late StreamSubscription<BluetoothConnectionState> _connectionStateSubscription;

  @override
  void initState() {
    super.initState();
    _connectionStateSubscription = widget.device.connectionState.listen((state) {
      _connectionState = state;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _connectionStateSubscription.cancel();
    super.dispose();
  }

  bool get isConnected {
    return _connectionState == BluetoothConnectionState.connected;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height:50,
      width: double.infinity,
      alignment: Alignment.center,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal:16),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(196, 196, 196, 0.25),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: CupertinoButton(
              minSize: 50,
              padding: EdgeInsets.zero,
              onPressed: widget.onDisconnect,
              child: Row(
                children: [
                  Text(
                    widget.device.platformName,
                    style: regularFontSize( 14 , Colors.black),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
          _buildDisconnectNInfoButton()
        ],
      ),
    );
  }

  Widget _buildDisconnectNInfoButton() {
    return Row(
      children: [
        CupertinoButton(
          minSize: 16,
          padding: EdgeInsets.zero,
          onPressed: widget.onOpen,
          child: Icon(Icons.info,size:16),
        ),
      ],
    );
  }
}
