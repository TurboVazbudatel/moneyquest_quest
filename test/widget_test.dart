import 'package:flutter_test/flutter_test.dart';
import 'package:moneyquest_quest/main.dart';

void main() {
  testWidgets('MoneyQuest smoke test', (tester) async {
    await tester.pumpWidget(const MoneyQuestApp());
    // Проверим, что корневой виджет отрисовался
    expect(find.byType(MoneyQuestApp), findsOneWidget);
  });
}
