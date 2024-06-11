import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class GraphPage extends StatelessWidget {
  final List<Map<String, String>> dummyData;

  const GraphPage({Key? key, required this.dummyData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Graph"),
      ),
      body: Center(
        child: buildGraphWidget(),
      ),
    );
  }

  Widget buildGraphWidget() {
    return SizedBox(
      height: 300,
      child: BarChart(
        BarChartData(
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(color: Colors.black),
                  );
                },
                reservedSize: 30,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value >= 0 && value < dummyData.length) {
                    return Text(
                      dummyData[value.toInt()]["client_name"] ?? "",
                      style: const TextStyle(color: Colors.black),
                    );
                  }
                  return const Text("");
                },
                reservedSize: 30,
              ),
            ),
          ),
          barGroups: generateGraphData("value"),
          borderData: FlBorderData(show: false),
          alignment: BarChartAlignment.spaceAround,
          barTouchData: BarTouchData(enabled: false),
          gridData: FlGridData(show: false),
        ),
      ),
    );
  }

  List<BarChartGroupData> generateGraphData(String metric) {
    List<BarChartGroupData> barChartData = [];
    for (int i = 0; i < dummyData.length; i++) {
      double value = double.parse(dummyData[i][metric]!);
      barChartData.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: value,
              color: Colors.primaries[i % Colors.primaries.length],
            )
          ],
        ),
      );
    }
    return barChartData;
  }
}
