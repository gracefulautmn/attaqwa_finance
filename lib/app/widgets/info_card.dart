import 'package:flutter/material.dart';
import '../themes/main_theme.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color? color;
  final InfoCardType type;

  const InfoCard({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    this.color,
    this.type = InfoCardType.info,
  });

  const InfoCard.tip({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.lightbulb_outline,
    this.color,
  }) : type = InfoCardType.tip;

  const InfoCard.warning({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.warning_amber_outlined,
    this.color,
  }) : type = InfoCardType.warning;

  const InfoCard.success({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.check_circle_outline,
    this.color,
  }) : type = InfoCardType.success;

  const InfoCard.info({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.info_outline,
    this.color,
  }) : type = InfoCardType.info;

  @override
  Widget build(BuildContext context) {
    Color cardColor = color ?? _getColorByType();
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: cardColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: cardColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: cardColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 12,
              color: cardColor.withOpacity(0.8),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorByType() {
    switch (type) {
      case InfoCardType.tip:
        return Colors.orange.shade700;
      case InfoCardType.warning:
        return kWarning;
      case InfoCardType.success:
        return kSuccess;
      case InfoCardType.info:
        return kSecondary;
    }
  }
}

enum InfoCardType {
  info,
  tip,
  warning,
  success,
}
