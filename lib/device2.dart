import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/*
xóa các khai báo của DeviceScreen2 


 */
class DeviceScreen2 extends StatefulWidget {
  const DeviceScreen2({super.key});
  @override
  State<DeviceScreen2> createState() => _DeviceComponent2();
}

class _DeviceComponent2 extends State<DeviceScreen2> {
  final DatabaseReference _dbRef =
      FirebaseDatabase.instance.ref('Energy/Today/value');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Column(
        children: [
          // Input display boxes
          Row(
            children: [
              Expanded(
                child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('Consumption : 200kWh'),
                    ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Cost: 700000kWh'),
                ),
              ),
            ],
          ),
          // Statistics table
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(child: Text('Statistics Table')),
            ),
          ),
        ],
      ),
    );
  }
}
