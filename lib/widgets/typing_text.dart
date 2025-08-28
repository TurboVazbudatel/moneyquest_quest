import 'dart:async';
import 'package:flutter/material.dart';

class TypingText extends StatefulWidget {
  final String text;
  final Duration speed;
  final TextStyle? style;
  const TypingText({super.key, required this.text, this.speed = const Duration(milliseconds: 35), this.style});

  @override
  State<TypingText> createState() => _TypingTextState();
}

class _TypingTextState extends State<TypingText> {
  late String _shown;
  Timer? _timer;
  int _i = 0;

  @override
  void initState() {
    super.initState();
    _shown = '';
    _timer = Timer.periodic(widget.speed, (t) {
      if (_i >= widget.text.length) {
        t.cancel();
      } else {
        setState(() {
          _shown = widget.text.substring(0, _i + 1);
          _i++;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(_shown, style: widget.style);
  }
}
