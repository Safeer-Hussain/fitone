import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ReasoningChip extends StatelessWidget {
  final String reasoning;

  const ReasoningChip({super.key, required this.reasoning});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.purpleAccent.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.purpleAccent.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(AppColors.purpleAccent),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              reasoning,
              style: const TextStyle(
                color: Color(0xFFD8B4FE),
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
