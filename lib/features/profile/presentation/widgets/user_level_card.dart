import 'package:flutter/material.dart';

import '../../../../core/utils/level_calculator.dart';

class UserLevelCard extends StatelessWidget {
  final int totalXp;

  const UserLevelCard({super.key, required this.totalXp});

  @override
  Widget build(BuildContext context) {
    final level = LevelCalculator.getLevel(totalXp);
    final title = LevelCalculator.getTitle(level);
    final progressValue = LevelCalculator.getProgress(totalXp);
    final currentLevelXp = LevelCalculator.getCurrentLevelXp(totalXp);
    final remainingXp = LevelCalculator.getRemainingXp(totalXp);
    final targetXp = LevelCalculator.xpPerLevel;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.military_tech_rounded,
                      color: Colors.amber,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cấp độ $level: $title',
                        style: const TextStyle(
                          color: Color(0xFF1B5E20),
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const Text(
                        "Tích XP từ thu gom rác",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.info_outline_rounded,
                  size: 20,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progressValue,
              minHeight: 5,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation(Color(0xFF2E7D32)),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$currentLevelXp / $targetXp XP",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Color(0xFF2E7D32),
                ),
              ),
              Text(
                "Cần $remainingXp XP lên cấp ${level + 1}",
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              Text(
                "$targetXp XP",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
