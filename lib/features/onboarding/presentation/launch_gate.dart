import 'package:flutter/material.dart';
import 'package:moneyquest_quest/core/services/first_run_service.dart';
import 'package:moneyquest_quest/features/home/presentation/home_screen.dart';
import 'package:moneyquest_quest/features/onboarding/presentation/onboarding_screen.dart';

class LaunchGate extends StatefulWidget {
  const LaunchGate({super.key});
  @override
  State<LaunchGate> createState() => _LaunchGateState();
}

class _LaunchGateState extends State<LaunchGate> {
  final _first = FirstRunService();

  @override
  void initState() {
    super.initState();
    _showOnboardingIfNeeded();
  }

  Future<void> _showOnboardingIfNeeded() async {
    final need = await _first.needOnboarding();
    if (!mounted || need != true) return;
    await _first.markSeen();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
  }
}
