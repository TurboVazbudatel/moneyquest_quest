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
  bool? _need;

  @override
  void initState() {
    super.initState();
    _first.needOnboarding().then((v) {
      if (!mounted) return;
      setState(() => _need = v);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_need == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_need == true) {
      return OnboardingScreen(onFinished: () async {
        await _first.markSeen();
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (r) => false,
        );
      });
    }
    return const HomeScreen();
  }
}
