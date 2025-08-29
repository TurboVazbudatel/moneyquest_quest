import 'package:flutter/material.dart';

class AiriGreetingBanner extends StatefulWidget {
  final String name;
  const AiriGreetingBanner({super.key, this.name = ''});

  @override
  State<AiriGreetingBanner> createState() => _AiriGreetingBannerState();
}

class _AiriGreetingBannerState extends State<AiriGreetingBanner> with SingleTickerProviderStateMixin {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final text = 'Добрый день, ${widget.name.isEmpty ? 'друг' : widget.name}! Я Airi';
    return AnimatedSlide(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      offset: _visible ? Offset.zero : const Offset(0, .1),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
        opacity: _visible ? 1 : 0,
        child: Card(
          elevation: 0,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/airi/half/Airi_half_01_wave.png',
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    text,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
