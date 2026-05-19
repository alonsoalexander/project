import 'package:flutter/foundation.dart';

// ignore: non_constant_identifier_names
dbugPrint(message) {
  if (kDebugMode) {
    debugPrint(message.toString());
  }
}
