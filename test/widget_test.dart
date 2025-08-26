import 'package:flutter_test/flutter_test.dart';
import 'package:moneyquest_quest/main.dart';
import 'package:moneyquest_quest/data/storage/hive_store.dart';
import 'package:hive/hive.dart';
import 'package:hive_test/hive_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await setUpTestHive();                   // in-memory Hive
    await Hive.openBox(HiveStore.txBox);     // открываем нужный бокс
  });

  tearDown(() async {
    await Hive.box(HiveStore.txBox).close(); // закрываем
    await tearDownTestHive();                // чистим память
  });

  testWidgets('MoneyQuest smoke test', (tester) async {
    await tester.pumpWidget(const MoneyQuestApp());
    expect(find.byType(MoneyQuestApp), findsOneWidget);
  });
}
