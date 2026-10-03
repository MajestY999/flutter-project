// Рисует индекс доверия и заголовки разделов обзорного интерфейса.
import 'package:flutter/material.dart';

import '../models/trust_level.dart';
import '../theme/app_colors.dart';

class TrustCard extends StatelessWidget {
  const TrustCard({
    super.key,
    required this.trust,
    required this.kept,
    required this.broken,
    required this.onAnalytics,
  });

  final int trust;
  final int kept;
  final int broken;
  final VoidCallback onAnalytics;

  @override
  Widget build(BuildContext context) {
    final status = levelForStats(trust: trust, kept: kept).name;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF28213B), Color(0xFF191823)],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: AppColors.violet.withValues(alpha: .19)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'ИНДЕКС ДОВЕРИЯ',
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFFB7B0C8),
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.lime.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.circle, size: 6, color: AppColors.lime),
                    SizedBox(width: 6),
                    Text(
                      'ОБЩИЙ',
                      style: TextStyle(
                        fontSize: 9,
                        color: AppColors.lime,
                        fontWeight: FontWeight.w700,
                        letterSpacing: .8,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$trust',
                            style: const TextStyle(
                              fontSize: 58,
                              height: .95,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -3,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(top: 4, left: 3),
                            child: Text(
                              '%',
                              style: TextStyle(
                                fontSize: 25,
                                color: AppColors.violet,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.violet.withValues(alpha: .15),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Text(
                        status,
                        style: const TextStyle(
                          color: Color(0xFFC9B9FF),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '$broken обещаний не сдержано',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              SizedBox(
                width: 108,
                height: 108,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 98,
                      height: 98,
                      child: CircularProgressIndicator(
                        value: trust / 100,
                        strokeWidth: 8,
                        strokeCap: StrokeCap.round,
                        backgroundColor: Colors.white.withValues(alpha: .08),
                        valueColor: const AlwaysStoppedAnimation(
                          AppColors.lime,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          trust >= 70
                              ? Icons.favorite_rounded
                              : Icons.heart_broken_rounded,
                          color: AppColors.lime,
                          size: 21,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'на сегодня',
                          style: TextStyle(fontSize: 9, color: AppColors.muted),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 19),
          Container(height: 1, color: Colors.white.withValues(alpha: .08)),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(
                Icons.auto_graph_rounded,
                color: AppColors.lime,
                size: 16,
              ),
              const SizedBox(width: 7),
              const Expanded(
                child: Text(
                  'Доверие требует доказательств',
                  style: TextStyle(fontSize: 11, color: Color(0xFFD4CFDF)),
                ),
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: onAnalytics,
                  child: const Text(
                    'Анализ →',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.lime,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SectionHeading extends StatelessWidget {
  const SectionHeading({
    super.key,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -.35,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 11, color: AppColors.muted),
              ),
            ],
          ),
        ),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: onAction,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                actionLabel,
                style: const TextStyle(
                  color: AppColors.lime,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
