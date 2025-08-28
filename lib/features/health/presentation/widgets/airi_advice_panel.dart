import 'package:flutter/material.dart';
import 'package:moneyquest_quest/data/services/airi_advice_service.dart';

class AiriAdvicePanel extends StatefulWidget {
  const AiriAdvicePanel({super.key});

  @override
  State<AiriAdvicePanel> createState() => _AiriAdvicePanelState();
}

class _AiriAdvicePanelState extends State<AiriAdvicePanel> {
  final _svc = AiriAdviceService();
  late Future<List<String>> _load;

  @override
  void initState() {
    super.initState();
    _load = _svc.suggestions();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder<List<String>>(
      future: _load,
      builder: (context, snap) {
        final tips = snap.data ?? const <String>[];
        return Card(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: tips.isEmpty
                ? const SizedBox.shrink()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Советы Airi', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 8),
                      ...tips.map((t) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('•  '),
                                Expanded(child: Text(t)),
                              ],
                            ),
                          )),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
