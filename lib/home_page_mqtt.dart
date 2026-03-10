import 'package:flutter/material.dart';
import 'flushing_service.dart';
import 'mqtt_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FlushingService _service = FlushingService(); /*แก้แล้วนี้ */
  late MqttService _mqtt;
  final String mobileClientId =
      '63654b3c-3aed-4575-bdea-6ae340dd9568'; // of Mobile App
  final String mobileToken =
      'uYFNZRPa6KAnQgS1Uvbp9kJYsQZ2Pk5L'; // of Mobile App
  final String mobileSecret =
      'nFPR4igYpGmYqnwat26TcX9xayv5dBFu'; // of Mobile App

  late bool isCanFlush;

  @override
  void initState() {
    super.initState();
   _service.getFlushingStatus().then((status) {
      setState(() {
        isCanFlush = status;
      });
    }).catchError((error) {
      print('Error fetching Flushing status: $error');
    });
    _mqtt = MqttService(
      clientId: mobileClientId,
      token: mobileToken,
      secret: mobileSecret,
      isFlushChanged: (status) {
        setState(() {
          isCanFlush = status;
        });
      },
    );
    _mqtt.connect();
  }

  @override
  void dispose() {
    _mqtt.disconnect();
    super.dispose();
  }

  Future<void> toggleFlush() async {
    setState(() {
      isCanFlush = false;
    });
    await _service.setFlushingStatus(true);
  }

  Widget CardLed([Color color = Colors.amber]) {
    return Card(
      margin: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.white,
      elevation: 1,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            isCanFlush ? 'assets/flushingBw.jpg' : 'assets/flushing.jpg',
            width: 150,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: isCanFlush
                    ?() {
                      toggleFlush();
                    }
                    : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isCanFlush ? color : Colors.grey,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              isCanFlush ? 'Can Flushing' : 'Flushing',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flushing Toilet Controller'),
        backgroundColor: Colors.blue,
      ),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [CardLed(Colors.green) /*แก้ตรงนี้ */],
        ),
      ),
    );
  }
}
