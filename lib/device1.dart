import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_database/firebase_database.dart';

class DeviceScreen extends StatefulWidget {
  const DeviceScreen({super.key});

  @override
  State<DeviceScreen> createState() => _DeviceComponent();
}

class _DeviceComponent extends State<DeviceScreen> {
  final List<double> energyData = [
    3,
    5,
    2,
    8,
    6,
    4,
    7,
    9,
    5,
    3,
    6,
    4,
    8,
    5,
    7,
    6,
    4,
    3,
    5,
    6,
    4,
    8,
    7,
    3
  ];
  final List<String> timeLabels = [
    "12 AM",
    "",
    "2 AM",
    "",
    "4 AM",
    "",
    "6 AM",
    "",
    "8 AM",
    "",
    "10 AM",
    "",
    "12 PM",
    "",
    "2 PM",
    "",
    "4 PM",
    "",
    "6 PM",
    "",
    "8 PM",
    "",
    "10 PM",
    ""
  ];
  final DatabaseReference _dbRef =
      FirebaseDatabase.instance.ref('Energy/Today/value');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Device Energy Dashboard',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF007BFF), Color(0xFF67C8FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Row for consumption and cost data
            Row(
              children: [
                _buildDataCard(
                  title: 'Consumption (kWh)',
                  streamBuilder: StreamBuilder(
                    stream: _dbRef.onValue,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Text("Error");
                      } else if (snapshot.hasData &&
                          snapshot.data!.snapshot.value != null) {
                        var data = snapshot.data!.snapshot.value;
                        return Text('$data kWh',
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold));
                      }
                      return const CircularProgressIndicator();
                    },
                  ),
                ),
                _buildDataCard(
                  title: 'Cost (VND)',
                  streamBuilder: StreamBuilder(
                    stream: _dbRef.onValue,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Text("Error");
                      } else if (snapshot.hasData &&
                          snapshot.data!.snapshot.value != null) {
                        var data = snapshot.data!.snapshot.value as int;
                        var money = data * 3500;
                        return Text('$money VND',
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold));
                      }
                      return const CircularProgressIndicator();
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Energy Usage Bar Chart
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E), // Màu nền tối
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(221, 244, 244, 244)
                          .withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${energyData.reduce((a, b) => a + b).toStringAsFixed(2)} kWh',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'USED',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 200,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: 1.4,
                          minY: 0,
                          barTouchData: BarTouchData(enabled: false),
                          titlesData: FlTitlesData(
                            show: true,
                            topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 0.7,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    value.toStringAsFixed(1),
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  );
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  int index = value.toInt();
                                  if (index % 6 == 0 &&
                                      index < timeLabels.length) {
                                    return Text(
                                      timeLabels[index].split(' ')[0],
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    );
                                  }
                                  return const SizedBox();
                                },
                              ),
                            ),
                          ),
                          gridData: FlGridData(
                            show: true,
                            horizontalInterval: 0.7,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: Colors.grey.withOpacity(0.2),
                                strokeWidth: 1,
                              );
                            },
                            drawVerticalLine: false,
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: energyData.asMap().entries.map((entry) {
                            int index = entry.key;
                            double value = entry.value /
                                10; // Chia để scale giá trị phù hợp
                            return BarChartGroupData(
                              x: index,
                              barRods: [
                                BarChartRodData(
                                  toY: value,
                                  color: const Color.fromARGB(255, 20, 97, 212),
                                  width: 3,
                                  borderRadius: BorderRadius.circular(0),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Placeholder for future statistics table
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'Statistics Table',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataCard(
      {required String title, required Widget streamBuilder}) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                )),
            const SizedBox(height: 8),
            streamBuilder,
          ],
        ),
      ),
    );
  }
}
