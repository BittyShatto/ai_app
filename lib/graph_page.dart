import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

enum ChartType {
  line,
  bar,
  pie,
}

class GraphPage extends StatefulWidget {
  final List<Map<String, String>> dummyData;
  final ChartType selectedChartType;

  const GraphPage(
      {Key? key, required this.dummyData, required this.selectedChartType})
      : super(key: key);

  @override
  _GraphPageState createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  ChartType? selectedChartType;

  @override
  void initState() {
    super.initState();
    selectedChartType = widget.selectedChartType;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Graph"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  title: Text("Line Chart"),
                  onTap: () {
                    setState(() {
                      selectedChartType = ChartType.line;
                    });
                  },
                ),
                ListTile(
                  title: Text("Bar Chart"),
                  onTap: () {
                    setState(() {
                      selectedChartType = ChartType.bar;
                    });
                  },
                ),
                ListTile(
                  title: Text("Pie Chart"),
                  onTap: () {
                    setState(() {
                      selectedChartType = ChartType.pie;
                    });
                  },
                ),
              ],
            ),
          ),
          if (selectedChartType != null)
            Expanded(
              child: Center(
                child: buildGraphWidget(),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildGraphWidget() {
    switch (selectedChartType) {
      case ChartType.line:
        return SizedBox(
          height: 300,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey,
                    strokeWidth: 1,
                  );
                },
                getDrawingVerticalLine: (value) {
                  return FlLine(
                    color: Colors.grey,
                    strokeWidth: 1,
                  );
                },
              ),
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
                      if (value >= 0 && value < widget.dummyData.length) {
                        return Text(
                          widget.dummyData[value.toInt()]["client_name"] ?? "",
                          style: const TextStyle(color: Colors.black),
                        );
                      }
                      return const Text("");
                    },
                    reservedSize: 30,
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.black, width: 1),
              ),
              minX: 0,
              maxX: (widget.dummyData.length - 1).toDouble(),
              minY: 0,
              maxY: 6,
              lineBarsData: [
                LineChartBarData(
                  spots: generateLineChartSpots(),
                  isCurved: true,
                  barWidth: 3,
                  color: Colors.blue, // Correcting parameter name
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.blue
                        .withOpacity(0.3), // Correcting parameter name
                  ),
                ),
              ],
            ),
          ),
        );
      case ChartType.bar:
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
                      if (value >= 0 && value < widget.dummyData.length) {
                        return Text(
                          widget.dummyData[value.toInt()]["client_name"] ?? "",
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
      case ChartType.pie:
        return SizedBox(
          height: 300,
          child: PieChart(
            PieChartData(
              sections: generatePieChartData(),
              borderData: FlBorderData(show: false),
              centerSpaceRadius: 40,
              sectionsSpace: 0,
              startDegreeOffset: 180,
              pieTouchData: PieTouchData(enabled: false),
            ),
          ),
        );
      default:
        return Container();
    }
  }

  List<FlSpot> generateLineChartSpots() {
    List<FlSpot> spots = [];
    for (int i = 0; i < widget.dummyData.length; i++) {
      double value = double.parse(widget.dummyData[i]["value"]!);
      spots.add(FlSpot(i.toDouble(), value));
    }
    return spots;
  }

  List<BarChartGroupData> generateGraphData(String metric) {
    List<BarChartGroupData> barChartData = [];
    for (int i = 0; i < widget.dummyData.length; i++) {
      double value = double.parse(widget.dummyData[i][metric]!);
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

  List<PieChartSectionData> generatePieChartData() {
    List<PieChartSectionData> pieChartData = [];
    for (int i = 0; i < widget.dummyData.length; i++) {
      double value = double.parse(widget.dummyData[i]["value"]!);
      pieChartData.add(
        PieChartSectionData(
          value: value,
          color: Colors.primaries[i % Colors.primaries.length],
        ),
      );
    }
    return pieChartData;
  }
}
