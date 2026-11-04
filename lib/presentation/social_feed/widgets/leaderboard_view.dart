import 'package:flutter/material.dart';

class LeaderboardView extends StatelessWidget {
  const LeaderboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.primary.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              Icon(Icons.military_tech_outlined, color: colorScheme.primary, size: 28),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Global Tonnage & Distance League',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: colorScheme.onSurface),
                    ),
                    Text(
                      'Weekly cohort resetting in 2 days 14 hours',
                      style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
                    ),
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
              color: isUser ? colorScheme.primary.withValues(alpha: 0.12) : colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isUser ? colorScheme.primary : colorScheme.outlineVariant,
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
                        : (rank == 2 ? const Color(0xFF94A3B8) : (rank == 3 ? const Color(0xFFB45309) : colorScheme.surfaceContainerHighest)),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$rank',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      color: rank <= 3 ? Colors.black : colorScheme.onSurface,
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
                          Flexible(
                            child: Text(
                              a['name'] as String,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: colorScheme.onSurface),
                            ),
                          ),
                          if (isUser) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'YOU',
                                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: colorScheme.primary),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        a['handle'] as String,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      a['volume'] as String,
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: colorScheme.primary),
                    ),
                    Text(
                      a['distance'] as String,
                      style: TextStyle(fontSize: 11, color: colorScheme.secondary),
                    ),
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
