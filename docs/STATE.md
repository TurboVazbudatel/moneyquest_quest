# MoneyQuest — STATE (2025-08-27)
Commit: 091f8df

## Завершено
- [x] ФинЗдоровье: линейный график (мятный), советы Airi
- [x] Диаграммы: радар — две круговые волны (glow), подписи по окружности, видим даже при нулях
- [x] Транзакции: доход/расход, категории, сохранение
- [x] Анонимный вход Firebase

## В работе
- [ ] Онбординг: анимация Airi, кнопки входа (Google/Apple/Telegram), переход на Home
- [ ] Челленджи и баллы
- [ ] Подписка (premium): ИИ-советы Airi и расширенные отчёты

## Файлы (lib/)
lib/.DS_Store
lib/data/services/achievements_service.dart
lib/data/services/airi_advice.dart
lib/data/services/auth_service.dart
lib/data/services/budgets_service.dart
lib/data/services/challenges_service.dart
lib/data/services/finance_snapshot_service.dart
lib/data/services/goals_service.dart
lib/data/services/points_service.dart
lib/data/services/profile_service.dart
lib/data/services/transactions_service.dart
lib/data/storage/hive_store.dart
lib/data/utils/categories.dart
lib/features/.DS_Store
lib/features/account/.DS_Store
lib/features/account/presentation/account_screen.dart
lib/features/achievements/.DS_Store
lib/features/achievements/presentation/achievements_screen.dart
lib/features/battle/.DS_Store
lib/features/battle/presentation/budget_battle_screen.dart
lib/features/budgets/.DS_Store
lib/features/budgets/presentation/add_budget_sheet.dart
lib/features/budgets/presentation/budgets_manager_screen.dart
lib/features/budgets/presentation/budgets_screen.dart
lib/features/goals/.DS_Store
lib/features/goals/presentation/goals_screen.dart
lib/features/health/.DS_Store
lib/features/health/presentation/health_screen.dart
lib/features/health/presentation/widgets/health_trend_chart.dart
lib/features/home/.DS_Store
lib/features/home/presentation/home_screen.dart
lib/features/onboarding/.DS_Store
lib/features/onboarding/presentation/onboarding_screen.dart
lib/features/points/.DS_Store
lib/features/points/presentation/points_screen.dart
lib/features/reports/.DS_Store
lib/features/reports/presentation/.DS_Store
lib/features/reports/presentation/reports_screen.dart
lib/features/reports/presentation/widgets/radar_income_expense.dart
lib/features/share/.DS_Store
lib/features/share/widgets/share_card.dart
lib/features/transactions/presentation/add_tx_sheet.dart
lib/features/transactions/presentation/transactions_screen.dart
lib/firebase_options.dart
lib/main.dart

## Экраны (классы *Screen)
 - lib/features/battle/presentation/budget_battle_screen.dart:7:class BudgetBattleScreen extends StatefulWidget {
 - lib/features/battle/presentation/budget_battle_screen.dart:14:class _BudgetBattleScreenState extends State<BudgetBattleScreen> {
 - lib/features/home/presentation/home_screen.dart:9:class HomeScreen extends StatefulWidget {
 - lib/features/home/presentation/home_screen.dart:16:class _HomeScreenState extends State<HomeScreen> {
 - lib/features/achievements/presentation/achievements_screen.dart:4:class AchievementsScreen extends StatefulWidget {
 - lib/features/achievements/presentation/achievements_screen.dart:11:class _AchievementsScreenState extends State<AchievementsScreen> {
 - lib/features/goals/presentation/goals_screen.dart:5:class GoalsScreen extends StatefulWidget {
 - lib/features/goals/presentation/goals_screen.dart:12:class _GoalsScreenState extends State<GoalsScreen> {
 - lib/features/health/presentation/health_screen.dart:6:class HealthScreen extends StatefulWidget {
 - lib/features/health/presentation/health_screen.dart:13:class _HealthScreenState extends State<HealthScreen> {
 - lib/features/transactions/presentation/transactions_screen.dart:5:class TransactionsScreen extends StatefulWidget {
 - lib/features/transactions/presentation/transactions_screen.dart:12:class _TransactionsScreenState extends State<TransactionsScreen> {
 - lib/features/budgets/presentation/budgets_screen.dart:4:class BudgetsScreen extends StatefulWidget {
 - lib/features/budgets/presentation/budgets_screen.dart:10:class _BudgetsScreenState extends State<BudgetsScreen> {
 - lib/features/budgets/presentation/budgets_manager_screen.dart:5:class BudgetsManagerScreen extends StatefulWidget {
 - lib/features/budgets/presentation/budgets_manager_screen.dart:12:class _BudgetsManagerScreenState extends State<BudgetsManagerScreen> {
 - lib/features/points/presentation/points_screen.dart:4:class PointsScreen extends StatefulWidget {
 - lib/features/points/presentation/points_screen.dart:11:class _PointsScreenState extends State<PointsScreen> {
 - lib/features/account/presentation/account_screen.dart:5:class AccountScreen extends StatefulWidget {
 - lib/features/account/presentation/account_screen.dart:12:class _AccountScreenState extends State<AccountScreen> {
 - lib/features/onboarding/presentation/onboarding_screen.dart:6:class OnboardingScreen extends StatefulWidget {
 - lib/features/onboarding/presentation/onboarding_screen.dart:13:class _OnboardingScreenState extends State<OnboardingScreen> {
 - lib/features/reports/presentation/reports_screen.dart:7:class ReportsScreen extends StatefulWidget {
 - lib/features/reports/presentation/reports_screen.dart:14:class _ReportsScreenState extends State<ReportsScreen> {
