import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../providers/entries_provider.dart';
import '../widgets/custom_app_bar.dart';

class AnalysisPage extends StatelessWidget {
  final String metricName;

  const AnalysisPage({
    super.key,
    required this.metricName,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EntriesProvider>(context);
    final all = provider.entriesForName(metricName)
      ..sort((a, b) => a.date.compareTo(b.date));

    final unit = all.isNotEmpty ? (all.first.unit ?? '') : '';
    final yAxisTitle = unit.isNotEmpty ? 'Value ($unit)' : 'Value';

    final chartData = all
        .map(
          (e) => _ChartPoint(
            date: DateTime(e.date.year, e.date.month, e.date.day),
            value: e.value,
            unit: e.unit,
          ),
        )
        .toList();

    return Scaffold(
      appBar: CustomAppBar(title: 'Analysis: $metricName'),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (chartData.isEmpty)
              const Expanded(
                child: Center(
                  child: Text('No data available'),
                ),
              )
            else
              Expanded(
                child: SfCartesianChart(
                  primaryXAxis: DateTimeAxis(
                      edgeLabelPlacement: EdgeLabelPlacement.shift),
                  primaryYAxis: NumericAxis(
                    title: AxisTitle(text: yAxisTitle),
                  ),
                  tooltipBehavior: TooltipBehavior(enable: true),
                  series: <ChartSeries<_ChartPoint, DateTime>>[
                    LineSeries<_ChartPoint, DateTime>(
                      dataSource: chartData,
                      xValueMapper: (_ChartPoint p, _) => p.date,
                      yValueMapper: (_ChartPoint p, _) => p.value,
                      dataLabelSettings:
                          const DataLabelSettings(isVisible: true),
                      markerSettings: const MarkerSettings(isVisible: true),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: chartData.length,
                itemBuilder: (context, index) {
                  final p = chartData[index];
                  final dateStr = DateFormat.yMd().format(p.date);
                  final u = p.unit ?? unit;
                  final valueText =
                      u.isEmpty ? '${p.value}' : '${p.value} $u';

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(dateStr),
                          const SizedBox(height: 8),
                          Text(
                            valueText,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _ChartPoint {
  final DateTime date;
  final int value;
  final String? unit;

  _ChartPoint({
    required this.date,
    required this.value,
    required this.unit,
  });
}
