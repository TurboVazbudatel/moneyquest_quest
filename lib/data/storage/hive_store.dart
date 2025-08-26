import 'package:hive_flutter/hive_flutter.dart';

class HiveStore {
  static const txBox = 'tx_box'; // хранит транзакции как Map<String,dynamic>

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(txBox);
  }

  static Box get boxTx => Hive.box(txBox);
}
