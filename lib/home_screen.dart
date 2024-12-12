import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'device1.dart';
import 'device2.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

Future<List<ChartData>> _fetchWeeklyData() async {
  final snapshot = await FirebaseDatabase.instance.ref('Energy/Week').get();
  if (snapshot.exists) {
    final data = Map<String, dynamic>.from(snapshot.value as Map);
    return data.entries.map((entry) {
      return ChartData(day: entry.key, value: entry.value as double);
    }).toList();
  } else {
    return [];
  }
}

class ChartData {
  final String day;
  final double value;

  ChartData({required this.day, required this.value});
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseReference _dbRef =
      FirebaseDatabase.instance.ref('Energy/Today/value');
  String selectedDevice = 'Home';

  void _logout() {
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Smart Energy Management',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 4,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF007BFF), Color(0xFF67C8FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          DropdownButton<String>(
            value: selectedDevice,
            dropdownColor: Colors.blueAccent,
            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
            underline: const SizedBox(), // Loại bỏ gạch dưới
            items: <String>['Home', 'Device 1', 'Device 2', 'Device 3']
                .map((String device) {
              return DropdownMenuItem<String>(
                value: device,
                child:
                    Text(device, style: const TextStyle(color: Colors.white)),
              );
            }).toList(),
            onChanged: (String? newDevice) {
              if (newDevice != null) {
                setState(() {
                  selectedDevice = newDevice;
                });

                if (newDevice == "Device 1") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DeviceScreen(),
                    ),
                  );
                }
                if (newDevice == "Device 2") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DeviceScreen2(),
                    ),
                  );
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
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
                        if (data is num) {
                          var dataT = data + 200;
                          return Text('$dataT kWh',
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold));
                        }
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
                        var dataT = data + 200;
                        var money = dataT * 3500;
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
            const SizedBox(height: 16), // statistics
/* ------------------------------------ code chỗ này là của phần Statistics ------------------------------------ */
            Expanded(
              //   child: Container(
              //     margin: const EdgeInsets.all(16),
              //     padding: const EdgeInsets.all(16),
              //     decoration: BoxDecoration(
              //       color: Colors.white,
              //       borderRadius: BorderRadius.circular(16),
              //       boxShadow: [
              //         BoxShadow(
              //           color: Colors.grey.withOpacity(0.2),
              //           blurRadius: 8,
              //           offset: const Offset(0, 4),
              //         ),
              //       ],
              //     ),
              //     child: Center(
              //       child: Text(   // code cho statisics
              //         'Statistics Table for $selectedDevice',
              //         style: const TextStyle(
              //           fontSize: 18,
              //           fontWeight: FontWeight.w600,
              //           color: Colors.blueAccent,
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
              child: Container(
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
                child: FutureBuilder(
                  future: _fetchWeeklyData(), // Hàm lấy dữ liệu từ Firebase
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return const Center(child: Text('Error loading data'));
                    } else if (snapshot.hasData) {
                      List<ChartData> chartData =
                          snapshot.data as List<ChartData>;
                      return Column(
                        children: [
                          const Text(
                            '\$99.22',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            child: Text('hello'),
                            // child: SfCartesianChart(
                            //   primaryXAxis: CategoryAxis(),
                            //   primaryYAxis: NumericAxis(
                            //     labelFormat: '\${value}', // Hiển thị giá trị
                            //   ),
                            //   series: <ChartSeries>[
                            //     ColumnSeries<ChartData, String>(
                            //       dataSource: chartData,
                            //       xValueMapper: (ChartData data, _) => data.day,
                            //       yValueMapper: (ChartData data, _) => data.value,
                            //       color: Colors.green,
                            //     )
                            //   ],
                            // ),
                          ),
                          const SizedBox(height: 10),
                          ToggleButtons(
                            isSelected: [true, false],
                            children: const [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Text('kWh'),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Text('\$'),
                              ),
                            ],
                            onPressed: (index) {
                              // Thêm logic chuyển đổi giữa dữ liệu kWh và $ nếu cần
                            },
                          ),
                        ],
                      );
                    }
                    return const Center(child: Text('No data available'));
                  },
                ),
              ),
            ),
/* ------------------------------------ code chỗ này là của phần VoiceScreen ------------------------------------ */
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/voice');
              },
              icon: const Icon(Icons.mic),
              label: const Text('Voice Input'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
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
