import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:timer_control/bluetooth/extra.dart';
import 'package:timer_control/bluetooth/snack_bar.dart';
import 'package:timer_control/typographies.dart';

class ScanResultTile extends StatefulWidget {
  final ScanResult result;
  final VoidCallback? onTap;
  const ScanResultTile({super.key, required this.result, this.onTap});
  @override
  State<ScanResultTile> createState() => _ScanResultTileState();
}

class _ScanResultTileState extends State<ScanResultTile>
    with SingleTickerProviderStateMixin {
  BluetoothConnectionState _connectionState =
      BluetoothConnectionState.disconnected;

  late AnimationController _loadingController;
  late StreamSubscription<BluetoothConnectionState>
      _connectionStateSubscription;

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(); // Repeat the animation
    _connectionStateSubscription = widget.result.device.connectionState.listen((state) {
      _connectionState = state;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _loadingController.dispose();
    _connectionStateSubscription.cancel();
    super.dispose();
  }

  String getNiceHexArray(List<int> bytes) {
    return '[${bytes.map((i) => i.toRadixString(16).padLeft(2, '0')).join(', ')}]';
  }

  String getNiceManufacturerData(List<List<int>> data) {
    return data.map((val) => getNiceHexArray(val)).join(', ').toUpperCase();
  }

  String getNiceServiceData(Map<Guid, List<int>> data) {
    return data.entries
        .map((v) => '${v.key}: ${getNiceHexArray(v.value)}')
        .join(', ')
        .toUpperCase();
  }

  String getNiceServiceUuids(List<Guid> serviceUuids) {
    return serviceUuids.join(', ').toUpperCase();
  }

  bool get isConnected {
    return _connectionState == BluetoothConnectionState.connected;
  }

  Widget _buildTitle(BuildContext context) {
    if (widget.result.device.platformName.isNotEmpty) {
      return Text(
        widget.result.device.platformName,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 14, color: Colors.black),
      );
    } else {
      return Text(
        widget.result.device.remoteId.str,
        style: regularFontSize(14, Colors.black),
      );
    }
  }

  Widget _buildLocalName(
      BuildContext context, String title, String value, String img) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          title,
          style:
              regularFontSize( 14 , Colors.grey),
        ),
        Text(
          value,
          style: regularFontSize( 14, Colors.black),
          softWrap: true,
        ),
        const Spacer(),
        CupertinoButton(
          minSize: 8,
          padding: EdgeInsets.zero,
          onPressed: () {},
          child: Image.asset(img, height: 8),
        ),
      ],
    );
  }

  Widget _buildAdvRow(BuildContext context, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style:
              regularFontSize(14 ,Colors.grey),
        ),
        Expanded(
          child: Text(
            value,
            style: regularFontSize( 14 , Colors.black),
            softWrap: true,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var adv = widget.result.advertisementData;
    var specificDevices = widget.result.device.platformName.isNotEmpty;
    return specificDevices
        ? Container(
            decoration: const BoxDecoration(
              border: Border(
                  bottom: BorderSide(width: 0.5, color: Colors.grey),
              ),
            ),
            child: ExpansionTile(
              tilePadding: EdgeInsets.symmetric(horizontal: 16),
              title: CupertinoButton(
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
                onPressed: widget.onTap,
                child: _buildTitle(context),
              ),
              trailing: _buildInfoButton(),
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 17,
                    vertical:17,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                    border: Border(
                      top: BorderSide(width: 0.5, color:Colors.grey),
                    ),
                  ),
                  child: Wrap(
                    runSpacing:16,
                    children: [
                      _buildLocalName(
                          context,
                          'Name: ',
                          (adv.advName.isNotEmpty) ? adv.advName : 'N/A',
                         '',
                      ),
                      _buildAdvRow(
                          context,
                          'Tx Power Level: ',
                          (adv.txPowerLevel != null)
                              ? '${adv.txPowerLevel}'
                              : 'N/A'),
                      _buildAdvRow(
                        context,
                        'Appearance: ',
                        ((adv.appearance ?? 0) > 0)
                            ? '0x${adv.appearance!.toRadixString(16)}'
                            : 'N/A',
                      ),
                      _buildAdvRow(
                        context,
                        'Manufacturer Data: ',
                        (adv.msd.isNotEmpty)
                            ? getNiceManufacturerData(adv.msd)
                            : 'N/A',
                      ),
                      _buildAdvRow(
                        context,
                        'Service UUIDs: ',
                        (adv.serviceUuids.isNotEmpty)
                            ? getNiceServiceUuids(adv.serviceUuids)
                            : 'N/A',
                      ),
                      Column(
                        children: [
                          _buildAdvRow(
                            context,
                            'Service Data: ',
                            (adv.serviceData.isNotEmpty)
                                ? getNiceServiceData(adv.serviceData)
                                : 'N/A',
                          ),
                         const SizedBox(height: 16),
                          _buildConnectButton(context),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        : Container();
  }

  Widget _buildConnectButton(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CupertinoButton(
          minSize: 32,
          padding: EdgeInsets.zero,
          onPressed: () async {
            widget.result.device.connectAndUpdateStream().catchError((e) {
              ASnackBar.show(ABC.b, prettyException("Connect Error:", e),
                  success: false);
            }).whenComplete(
              () => Navigator.of(context).pop(),
            );
          },
          child: Container(
            height:32,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.25),
                    blurRadius: 1,
                  ),
                ]),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoButton() {
    return const Icon(Icons.info, color: Colors.black, size: 18);
  }
}
