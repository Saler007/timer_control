import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:timer_control/bluetooth/snack_bar.dart';
import 'package:timer_control/typographies.dart';


import "descriptor_tile.dart";

class CharacteristicTile extends StatefulWidget {
  final BluetoothCharacteristic characteristic;
  final List<DescriptorTile> descriptorTiles;

  const CharacteristicTile(
      {super.key, required this.characteristic, required this.descriptorTiles});

  @override
  State<CharacteristicTile> createState() => _CharacteristicTileState();
}

class _CharacteristicTileState extends State<CharacteristicTile> {
  List<int> _value = [];

  late StreamSubscription<List<int>> _lastValueSubscription;

  @override
  void initState() {
    super.initState();
    _lastValueSubscription = widget.characteristic.lastValueStream.listen((value) {
      _value = value;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _lastValueSubscription.cancel();
    super.dispose();
  }

  BluetoothCharacteristic get c => widget.characteristic;

  List<int> _getRandomBytes() {
    final math = Random();
    return [
      math.nextInt(255),
      math.nextInt(255),
      math.nextInt(255),
      math.nextInt(255)
    ];
  }

  Future onReadPressed() async {
    try {
      await c.read();
      ASnackBar.show(ABC.c, "Read: Success", success: true);
    } catch (e) {
      ASnackBar.show(ABC.c, prettyException("Read Error:", e), success: false);
    }
  }

  Future onWritePressed() async {
    try {
      await c.write(_getRandomBytes(),
          withoutResponse: c.properties.writeWithoutResponse);
      ASnackBar.show(ABC.c, "Write: Success", success: true);
      if (c.properties.read) {
        await c.read();
      }
    } catch (e) {
      ASnackBar.show(ABC.c, prettyException("Write Error:", e), success: false);
    }
  }

  Future onSubscribePressed() async {
    try {
      String op = c.isNotifying == false ? "Subscribe" : "Unsubscribe";
      await c.setNotifyValue(c.isNotifying == false);
      ASnackBar.show(ABC.c, "$op : Success", success: true);
      if (c.properties.read) {
        await c.read();
      }
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      ASnackBar.show(ABC.c, prettyException("Subscribe Error:", e),
          success: false);
    }
  }

  Widget buildUuid(BuildContext context) {
    String uuid = '0x${widget.characteristic.uuid.str.toUpperCase()}';
    return Text(uuid, style: regularFontSize(16, Colors.black));
  }

  Widget buildValue(BuildContext context) {
    String data = _value.toString();
    return Text(data, style: regularFontSize(16, Colors.black));
  }

  Widget buildReadButton(BuildContext context) {
    return TextButton(
      onPressed: () async {
        await onReadPressed();
        if (mounted) {
          setState(() {});
        }
      },
      child: Text("Read", style: regularFontSize(16, Colors.black)),
    );
  }

  Widget buildWriteButton(BuildContext context) {
    bool withoutResp = widget.characteristic.properties.writeWithoutResponse;
    return TextButton(
      onPressed: () async {
        await onWritePressed();
        if (mounted) {
          setState(() {});
        }
      },
      child: Text(
        withoutResp ? "WriteNoResp" : "Write",
        style: regularFontSize(16, Colors.black),
      ),
    );
  }

  Widget buildSubscribeButton(BuildContext context) {
    bool isNotifying = widget.characteristic.isNotifying;
    return TextButton(
      onPressed: () async {
        await onSubscribePressed();
        if (mounted) {
          setState(() {});
        }
      },
        child: Text(
          isNotifying ? "Unsubscribe" : "Subscribe",
          style: regularFontSize(16, Colors.black),
        ),
      );
  }

  Widget buildButtonRow(BuildContext context) {
    bool read = widget.characteristic.properties.read;
    bool write = widget.characteristic.properties.write;
    bool notify = widget.characteristic.properties.notify;
    bool indicate = widget.characteristic.properties.indicate;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (read) buildReadButton(context),
        if (write) buildWriteButton(context),
        if (notify || indicate) buildSubscribeButton(context),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.grey,
        border: Border(top: BorderSide(width: 0.5, color: Colors.grey)),
      ),
      child: ExpansionTile(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                Text('Characteristic: ', style: regularFontSize(16, Colors.black)),
                buildUuid(context),
              ],
            ),
            buildValue(context),
            buildButtonRow(context),
          ],
        ),
        children: widget.descriptorTiles,
      ),
    );
  }
}
