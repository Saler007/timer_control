
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../size_config.dart';

/* Circle Loading */
void popUpCircleLoading(context, AnimationController controller) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.transparent,
    builder: (context) {
      return Center(
        child: RotationTransition(
          turns: controller,
          child: SizedBox(
            height: heightConfig(35),
            width: widthConfig(35),
            child: const Icon(Icons.refresh),
          ),
        ),
      );
    },
  );
}

Future<void> popUpConnectMessage(BuildContext context, String messages) async {
  showDialog(
    context: context,
    barrierColor: Colors.transparent,
    barrierDismissible: false,
    builder: (context) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Container(
            height: 38,
            width: 153,
            margin: const EdgeInsets.only(bottom: 150),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(2),
            ),
            child: Text(
              messages,
              style: const TextStyle(fontSize: 12, color: Colors.black),
            ),
          ),
        ),
      );
    },
  );
  await Future.delayed(const Duration(milliseconds: 500));
  Navigator.of(context).pop();
}

/* Disconnect message */
void popUpDisconnectMessage(BuildContext context, BluetoothDevice device,
    {required Function() onPressed}) async {
  showDialog(
    context: context,
    barrierColor: const Color.fromRGBO(0, 0, 0, 0.2),
    builder: (context) {
      return Material(
        color: Colors.transparent,
        child: Center(
          child: Container(
            height: 136,
            width: 342,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.25),
                  offset: Offset(0, 0),
                  blurRadius: 2,
                )
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(),
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Disconnect Device\n"${device.platformName}"?',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: CupertinoButton(
                          padding: const EdgeInsets.only(right: 14),
                          onPressed: () => Navigator.of(context).pop(),
                          minSize: 22,
                          child: const Icon(
                            Icons.backspace_outlined,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                CupertinoButton(
                  minSize: 18,
                  padding: EdgeInsets.zero,
                  onPressed: onPressed,
                  child: Container(
                    height: 32,
                    width: 98,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 2,
                            color: Color.fromRGBO(0, 0, 0, 0.25),
                          )
                        ]),
                    child: const Text(
                      'Disconnect',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      );
    },
  );
}

/* Connect message */
Future<void> popUpComingSoon(BuildContext context) async {
  showDialog(
    context: context,
    barrierColor: Colors.transparent,
    barrierDismissible: false,
    builder: (context) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Container(
            height: 38,
            width: 153,
            margin: const EdgeInsets.only(bottom: 150),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(2),
            ),
            child: const Text(
              'Coming soon ...',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
      );
    },
  );
  await Future.delayed(const Duration(milliseconds: 500));
  Navigator.of(context).pop();
}

/* Connection lost message */
void popUpConnectionLost(BuildContext context, Function() onPressed) async {
  showDialog(
    barrierColor: const Color.fromRGBO(0, 0, 0, 0.1),
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return Material(
        color: Colors.transparent,
        child: Center(
          child: Container(
            height: 180,
            width: 342,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.25),
                  offset: Offset(0, 0),
                  blurRadius: 2,
                )
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Column(
                children: [
                  Container(
                    height: 48,
                    decoration:
                        const BoxDecoration(color: Colors.white, boxShadow: [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.25),
                        blurRadius: 1,
                      ),
                    ]),
                    child: Row(
                      children: [
                        const Spacer(),
                        const Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Connection Lost!',
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: CupertinoButton(
                              minSize: 22,
                              padding: const EdgeInsets.only(right: 14),
                              onPressed: onPressed,
                              child: const Icon(Icons.backspace_outlined,
                                  size: 22),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(),
                        Container(
                          alignment: Alignment.center,
                          child: const Text(
                            'Please check your connection.',
                            style: TextStyle(fontSize: 12, color: Colors.black),
                          ),
                        ),
                        CupertinoButton(
                          minSize: 32,
                          padding: EdgeInsets.zero,
                          onPressed: onPressed,
                          child: Container(
                            height: 32,
                            width: 84,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color.fromRGBO(0, 0, 0, 0.25),
                                  offset: Offset(0, 0),
                                  blurRadius: 2,
                                )
                              ],
                            ),
                            child: const Text(
                              'Try again',
                              style: TextStyle(
                               fontSize: 14,
                               color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        Container(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
