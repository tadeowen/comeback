import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class RatingDistributionChart extends StatelessWidget {
  final Map<int, int> starCounts;
  final List<Color> ratingColors = const [
    Color(0xFFFF0000), // 1★ Red
    Color(0xFFFF6B6B), // 2★ Light Red
    Color(0xFFFFD166), // 3★ Yellow
    Color(0xFF06D6A0), // 4★ Teal
    Color(0xFF118AB2), // 5★ Blue
  ];

  const RatingDistributionChart({
    Key? key,
    required this.starCounts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final chartData = starCounts.entries
        .map((e) => ChartData('${e.key}★', e.value, ratingColors[e.key - 1]))
        .toList();

    return SfCartesianChart(
      primaryXAxis: CategoryAxis(
        title: AxisTitle(text: 'Star Rating'),
        labelPlacement: LabelPlacement.onTicks,
      ),
      primaryYAxis: NumericAxis(
        title: AxisTitle(text: 'Number of Ratings'),
        minimum: 0,
        interval: 1,
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <ChartSeries<ChartData, String>>[
        BarSeries<ChartData, String>(
          dataSource: chartData,
          xValueMapper: (data, _) => data.category,
          yValueMapper: (data, _) => data.value,
          color: Colors.blue,
          pointColorMapper: (data, _) => data.color,
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            textStyle: TextStyle(fontWeight: FontWeight.bold),
          ),
          borderRadius: BorderRadius.circular(5),
        )
      ],
    );
  }
}

class ChartData {
  final String category;
  final int value;
  final Color color;

  ChartData(this.category, this.value, this.color);
}
