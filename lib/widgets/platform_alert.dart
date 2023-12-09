import 'package:flutter/material.dart';
import 'package:flutter_platform_alert/flutter_platform_alert.dart';

Future<AlertButton> platformInfo(BuildContext context, status, message) {
  return FlutterPlatformAlert.showAlert(
    iconStyle: IconStyle.information,
    windowTitle: status,
    text: message,
  );
}

Future<AlertButton> platformError(BuildContext context, status, message) {
  return FlutterPlatformAlert.showAlert(
    iconStyle: IconStyle.error,
    windowTitle: status,
    text: message,
  );
}
