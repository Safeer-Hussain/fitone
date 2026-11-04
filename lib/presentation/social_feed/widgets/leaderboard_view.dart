import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class LeaderboardView extends StatelessWidget {
  const LeaderboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final athletes = [
      {'rank': 1, 'name': 'Safeer Hussain', 'handle': '@safeer_h', 'volume': '18,450 kg', 'distance': '42.8 km', 'isUser': true},
      {'rank': 2, 'name': 'Zainab Tariq', 'handle': '@zainab_runs', 'volume': '14,200 kg', 'distance': '58.4 km', 'isUser': false},
      {'rank': 3, 'name': 'Liam O Connor', 'handle': '@liam_athletics', 'volume': '16,800 kg', 'distance': '31.2 km', 'isUser': false},
      {'rank': 4, 'name': 'Marcus Vance', 'handle': '@mvance_fit', 'volume': '12,900 kg', 'distance': '28.0 km', 'isUser': false},
      {'rank': 5, 'name': 'Elena Rostova', 'handle': '@elena_lift', 'volume': '15,100 kg', 'distance': '22.5 km', 'isUser': false},
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.emeraldPrimary.withOpacity(0.4)),
          ),
          child: const Row(
            children: [
              Icon(Icons.emoji_events_outlined, color: AppColors.emeraldPrimary, size: 28),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Global Tonnage & Distance League', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.white)),
                    Text('Weekly cohort resetting in 2 days 14 hours', style: TextStyle(fontSize: 11, color: AppColors.darkTextSecondary)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...athletes.map((a) {
          final isUser = a['isUser'] as bool;
          final rank = a['rank'] as int;

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isUser ? AppColors.emeraldPrimary.withOpacity(0.12) : AppColors.darkSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isUser ? AppColors.emeraldPrimary : AppColors.darkBorder,
                width: isUser ? 1.5 : 1.0,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: rank == 1
                        ? const Color(0xFFEAB308)
                        : (rank == 2 ? const Color(0xFF94A3B8) : (rank == 3 ? const Color(0xFFB45309) : AppColors.darkSurfaceElevated)),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$rank',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      color: rank <= 3 ? Colors.black : Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(a['name'] as String, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.white)),
                          if (isUser) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppColors.emeraldPrimary.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('YOU', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.emeraldPrimary)),
                            ),
                          ],
                        ],
                      ),
                      Text(a['handle'] as String, style: const TextStyle(fontSize: 11, color: AppColors.darkTextMuted)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(a['volume'] as String, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.emeraldPrimary)),
                    Text(a['distance'] as String, style: const TextStyle(fontSize: 11, color: AppColors.cyanAccent)),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
