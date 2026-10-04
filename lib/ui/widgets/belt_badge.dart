import 'package:flutter/material.dart';
import '../../data/models/belt_rank.dart';

class BeltBadge extends StatelessWidget {
  const BeltBadge({
    super.key,
    required this.belt,
    this.size = BeltBadgeSize.medium,
    this.showLabel = true,
  });

  final BeltRank belt;
  final BeltBadgeSize size;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final height = switch (size) {
      BeltBadgeSize.small => 22.0,
      BeltBadgeSize.medium => 28.0,
      BeltBadgeSize.large => 36.0,
    };

    final fontSize = switch (size) {
      BeltBadgeSize.small => 11.0,
      BeltBadgeSize.medium => 13.0,
      BeltBadgeSize.large => 15.0,
    };

    final padding = switch (size) {
      BeltBadgeSize.small => const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      BeltBadgeSize.medium => const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      BeltBadgeSize.large => const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    };

    return Container(
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: belt.color,
        borderRadius: BorderRadius.circular(height / 2),
        border: Border.all(
          color: belt == BeltRank.branca ? Colors.grey.shade400 : Colors.black26,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: belt.color.withValues(alpha: 0.35),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Tactical knot / tip of belt representation
          Container(
            width: 6,
            height: height * 0.6,
            decoration: BoxDecoration(
              color: belt.textColor.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          if (showLabel) ...[
            const SizedBox(width: 6),
            Text(
              belt.shortName.toUpperCase(),
              style: TextStyle(
                color: belt.textColor,
                fontSize: fontSize,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

enum BeltBadgeSize { small, medium, large }
