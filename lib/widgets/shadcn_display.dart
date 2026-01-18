import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';


// ==========================================
// 10. CARD
// ==========================================
class ShadcnCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const ShadcnCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24)
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ShadcnTheme.card,
        borderRadius: BorderRadius.circular(ShadcnTheme.radiusLg), // 24.0
        border: Border.all(color: ShadcnTheme.border),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(ShadcnTheme.radiusLg),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class ShadcnCardHeader extends StatelessWidget {
  final String title;
  final String? description;
  const ShadcnCardHeader({super.key, required this.title, this.description});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: ShadcnTheme.textStyle.copyWith(fontSize: 20, fontWeight: FontWeight.w600)),
        if (description != null) ...[
          const SizedBox(height: 6),
          Text(description!, style: ShadcnTheme.textStyle.copyWith(color: ShadcnTheme.mutedForeground)),
        ],
      ],
    );
  }
}

// ==========================================
// 11. CAROUSEL
// ==========================================
class ShadcnCarousel extends StatefulWidget {
  final List<Widget> items;
  const ShadcnCarousel({super.key, required this.items});

  @override
  State<ShadcnCarousel> createState() => _ShadcnCarouselState();
}

class _ShadcnCarouselState extends State<ShadcnCarousel> {
  final PageController _controller = PageController(viewportFraction: 0.85);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: PageView.builder(
        controller: _controller,
        itemCount: widget.items.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: widget.items[index],
          );
        },
      ),
    );
  }
}

// ==========================================
// 12. CHART (Line Chart Wrapper for fl_chart)
// ==========================================
class ShadcnLineChart extends StatelessWidget {
  final List<FlSpot> data;
  const ShadcnLineChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(color: ShadcnTheme.border, strokeWidth: 1),
          ),
          titlesData: const FlTitlesData(show: false), // Simplified for Shadcn minimalist look
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: data,
              isCurved: true,
              color: ShadcnTheme.primary,
              barWidth: 2,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: true, color: ShadcnTheme.primary.withOpacity(0.1)),
            ),
          ],
        ),
      ),
    );
  }
}