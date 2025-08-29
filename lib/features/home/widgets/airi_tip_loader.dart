import 'package:flutter/material.dart';
import 'package:moneyquest_quest/data/services/airi_advice.dart';
import 'package:moneyquest_quest/features/home/widgets/airi_tip_card.dart';

class AiriTipLoader extends StatelessWidget {
  const AiriTipLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: AiriAdviceService().advice(income: 45000, expense: 31000, goal: 50000),
      builder: (context, snap) {
        if (!snap.hasData || (snap.data ?? '').isEmpty) {
          return const SizedBox.shrink();
        }
        return AiriTipCard(text: snap.data!);
      },
    );
  }
}
