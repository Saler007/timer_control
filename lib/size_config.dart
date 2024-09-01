import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class ScreenSize {
  static late MediaQueryData _mediaQueryData;
  static late double w;
  static late double h;
  static Orientation? o;
  static late int mockupHeight;
  static late int mockupWidth;
  static late double scaleFactorW;
  static late double scaleFactorH;
  static late double scaleFactorSize;
  static late bool isPortrait;
  static bool isMobile = false;

  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    w = _mediaQueryData.size.width;  // Get the user screen width
    h = _mediaQueryData.size.height; // Get the user screen height
    o = _mediaQueryData.orientation; // Get the user screen orientation

    // (1024, 1366) is the layout (height, width) that UI/UX use for Tablet
    // (932, 430) is the layout (height, width) that UI/UX use for Mobile
    if( o == Orientation.landscape) {
      isPortrait = false;
      if(h <= 430 ){
        isMobile = true;
      }else {
        isMobile = false;
      }
      // tablet layout
      mockupHeight = 1024;
      mockupWidth = 1366;
      scaleFactorW = w / mockupWidth;
      scaleFactorH =  h / mockupHeight;
      scaleFactorSize = scaleFactorW;
    } else if (o == Orientation.portrait){
      isPortrait = true;
      mockupHeight = 932;
      mockupWidth = 430;
      scaleFactorW = w / mockupWidth;
      scaleFactorH =  h / mockupHeight;
      scaleFactorSize = scaleFactorH;
    }
  }
}

// Calculate the responsive font size
double fontConfig(double fontSize) {
  return (fontSize * ScreenSize.scaleFactorSize);
}

// Calculate the responsive height
double heightConfig(double inputHeight) {
  return (inputHeight * ScreenSize.scaleFactorH);
}

// Calculate the responsive width
double widthConfig(double inputWidth) {
  return (inputWidth * ScreenSize.scaleFactorW);
}
