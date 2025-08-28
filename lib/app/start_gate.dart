import 'package:flutter/material.dart';
import 'package:moneyquest_quest/data/services/profile_service.dart';
import 'package:moneyquest_quest/features/onboarding/presentation/onboarding_screen.dart';
import 'package:moneyquest_quest/features/home/presentation/home_screen.dart';

class StartGate extends StatelessWidget {
  const StartGate({super.key});

  Future<bool> _isOnboarded() => ProfileService().isOnboarded();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isOnboarded(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Material(
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final onb = snap.data ?? false;
        return onb ? const HomeScreen() : const OnboardingScreen();
      },
    );
  }
}
