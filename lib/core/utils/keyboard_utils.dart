import 'package:flutter/material.dart';

/// Wraps any widget tree with tap-to-dismiss behavior for the software keyboard.
class TapToDismissKeyboard extends StatelessWidget {
  final Widget child;

  const TapToDismissKeyboard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      behavior: HitTestBehavior.translucent,
      child: child,
    );
  }
}

/// Provides a managed FocusNode that automatically triggers `Scrollable.ensureVisible`
/// whenever the input field gains focus, preventing software keyboard occlusions.
class AutoScrollOnFocus extends StatefulWidget {
  final Widget Function(BuildContext context, FocusNode focusNode) builder;
  final double alignment;
  final Duration delay;

  const AutoScrollOnFocus({
    super.key,
    required this.builder,
    this.alignment = 0.5,
    this.delay = const Duration(milliseconds: 150),
  });

  @override
  State<AutoScrollOnFocus> createState() => _AutoScrollOnFocusState();
}

class _AutoScrollOnFocusState extends State<AutoScrollOnFocus> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      Future.delayed(widget.delay, () {
        if (mounted && _focusNode.hasFocus) {
          Scrollable.ensureVisible(
            context,
            alignment: widget.alignment,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _focusNode);
  }
}
