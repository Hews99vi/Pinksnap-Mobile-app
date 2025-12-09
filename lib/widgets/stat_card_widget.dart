import 'package:flutter/material.dart';
import '../config/admin_design_constants.dart';

/// Professional Stat Card with hover effects, trending indicators
/// Follows enterprise dashboard design patterns
class StatCardWidget extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;
  final double? trendPercentage;
  final bool? isPositiveTrend;
  final VoidCallback? onTap;

  const StatCardWidget({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
    this.trendPercentage,
    this.isPositiveTrend,
    this.onTap,
  });

  @override
  State<StatCardWidget> createState() => _StatCardWidgetState();
}

class _StatCardWidgetState extends State<StatCardWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AdminDesignConstants.transitionFast,
          curve: AdminDesignConstants.transitionCurve,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AdminDesignConstants.borderRadiusLarge,
            boxShadow: _isHovered
                ? AdminDesignConstants.shadowHover
                : AdminDesignConstants.shadowMedium,
            border: Border.all(
              color: _isHovered
                  ? widget.color.withValues(alpha: 0.3)
                  : AdminDesignConstants.gray200,
              width: 1,
            ),
          ),
          child: Padding(
            padding: AdminDesignConstants.paddingCard.copyWith(
              top: AdminDesignConstants.spacing20,
              bottom: AdminDesignConstants.spacing20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row: Icon and Trend
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Icon Container
                    Container(
                      padding: const EdgeInsets.all(
                        AdminDesignConstants.spacing12,
                      ),
                      decoration: BoxDecoration(
                        color: widget.color.withValues(alpha: 0.1),
                        borderRadius: AdminDesignConstants.borderRadiusMedium,
                      ),
                      child: Icon(
                        widget.icon,
                        size: AdminDesignConstants.iconSizeXl,
                        color: widget.color,
                      ),
                    ),

                    // Trend Indicator
                    if (widget.trendPercentage != null)
                      _buildTrendIndicator(),
                  ],
                ),

                const SizedBox(height: AdminDesignConstants.spacing16),

                // Value (Large Number)
                Text(
                  widget.value,
                  style: AdminDesignConstants.headlineLarge.copyWith(
                    color: AdminDesignConstants.textPrimary,
                    fontSize: 40,
                    fontWeight: AdminDesignConstants.fontWeightBold,
                    letterSpacing: -1,
                  ),
                ),

                const SizedBox(height: AdminDesignConstants.spacing8),

                // Title
                Text(
                  widget.title,
                  style: AdminDesignConstants.bodyMedium.copyWith(
                    color: AdminDesignConstants.textSecondary,
                    fontWeight: AdminDesignConstants.fontWeightMedium,
                  ),
                ),

                // Subtitle (Optional)
                if (widget.subtitle != null) ...[
                  const SizedBox(height: AdminDesignConstants.spacing4),
                  Text(
                    widget.subtitle!,
                    style: AdminDesignConstants.bodySmall.copyWith(
                      color: AdminDesignConstants.textTertiary,
                    ),
                  ),
                ],

                // Hover Action Indicator
                if (_isHovered && widget.onTap != null)
                  Padding(
                    padding: const EdgeInsets.only(
                      top: AdminDesignConstants.spacing8,
                    ),
                    child: Row(
                      children: [
                        Text(
                          'View Details',
                          style: AdminDesignConstants.bodySmall.copyWith(
                            color: widget.color,
                            fontWeight: AdminDesignConstants.fontWeightMedium,
                          ),
                        ),
                        const SizedBox(width: AdminDesignConstants.spacing4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: AdminDesignConstants.iconSizeSmall,
                          color: widget.color,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrendIndicator() {
    final isPositive = widget.isPositiveTrend ?? true;
    final trendColor = isPositive
        ? AdminDesignConstants.successGreen
        : AdminDesignConstants.dangerRed;
    final bgColor = isPositive
        ? AdminDesignConstants.successGreenLight
        : AdminDesignConstants.dangerRedLight;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AdminDesignConstants.spacing8,
        vertical: AdminDesignConstants.spacing4,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AdminDesignConstants.borderRadiusSmall,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive
                ? Icons.trending_up_rounded
                : Icons.trending_down_rounded,
            size: AdminDesignConstants.iconSizeSmall,
            color: trendColor,
          ),
          const SizedBox(width: AdminDesignConstants.spacing4),
          Text(
            '${widget.trendPercentage!.abs().toStringAsFixed(1)}%',
            style: AdminDesignConstants.bodySmall.copyWith(
              color: trendColor,
              fontWeight: AdminDesignConstants.fontWeightBold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact version for smaller displays
class CompactStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const CompactStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AdminDesignConstants.spacing12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AdminDesignConstants.borderRadiusMedium,
        boxShadow: AdminDesignConstants.shadowSmall,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AdminDesignConstants.spacing8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: AdminDesignConstants.borderRadiusSmall,
            ),
            child: Icon(
              icon,
              size: AdminDesignConstants.iconSizeMedium,
              color: color,
            ),
          ),
          const SizedBox(width: AdminDesignConstants.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: AdminDesignConstants.headlineSmall.copyWith(
                    color: AdminDesignConstants.textPrimary,
                    fontWeight: AdminDesignConstants.fontWeightBold,
                  ),
                ),
                const SizedBox(height: AdminDesignConstants.spacing4),
                Text(
                  title,
                  style: AdminDesignConstants.bodySmall.copyWith(
                    color: AdminDesignConstants.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
