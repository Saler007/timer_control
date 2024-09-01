
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import "characteristic_tile.dart";

class ServiceTile extends StatelessWidget {
  final BluetoothService service;
  final List<CharacteristicTile> characteristicTiles;

  const ServiceTile(
      {super.key, required this.service, required this.characteristicTiles});

  Widget buildUuid(BuildContext context) {
    String uuid = '0x${service.uuid.str.toUpperCase()}';
    return Text(uuid, style:const TextStyle(fontSize: 16, color: Colors.black));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(width: 0.5, color: Colors.grey)),
      ),
      child:  characteristicTiles.isNotEmpty
          ? ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const Text('Service: ', style: TextStyle(fontSize: 16, color: Colors.black)),
            buildUuid(context),
          ],
        ),
        children: characteristicTiles,
      ) : Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Text('Service: ', style: TextStyle(fontSize: 16, color: Colors.black)),
          buildUuid(context),
        ],
      ),
    );
  }
}
