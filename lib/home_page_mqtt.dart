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
  final String mobileClientId = ''; // of Mobile App
  final String mobileToken = ''; // of Mobile App
  final String mobileSecret = ''; // of Mobile App

  bool _isCanFlushingOn = false;
  bool _isCantFlushingOn = false;
  bool _isWaitingResponse = false;

  @override
  void initState() {
    super.initState();
    _mqtt = MqttService(
      clientId: mobileClientId,
      token: mobileToken,
      secret: mobileSecret,
      onLedStatusChanged: (status) {
        setState(() {
          print(status);
          _isCanFlushingOn = status;
          _isCantFlushingOn = status;
          _isWaitingResponse = false; // Enable button again
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

  Future<void> _toggleLed(String type, bool value) async {
    setState(() {
      _isWaitingResponse = true; // Disable button
      if (type == "led1") {
        /*แก้ตรงนี้ */
        _isCanFlushingOn = value;
      } else if (type == "led2") {
        /*แก้ตรงนี้ */
        _isCantFlushingOn = value;
      }
    });
    await _service.setFlushingStatus(type, value); /*แก้แล้วมั้ง */
  }

  Widget CardLed(String type, bool checkvalue, [Color color = Colors.amber]) {
    return Card(
      margin: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.white,
      elevation: 1,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            checkvalue ? 'assets/flushingBw.jpg' : 'assets/flushing.jpg',
            width: 150,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed:
                _isWaitingResponse
                    ? null
                    : () {
                      _toggleLed(type, !checkvalue);
                    },
            style: ElevatedButton.styleFrom(
              backgroundColor: checkvalue ? color : Colors.grey,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              checkvalue ? 'Flushing' : 'Can Flushing',
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
          children: [
            CardLed("led1", _isCanFlushingOn, Colors.green) /*แก้ตรงนี้ */,
          ],
        ),
      ),
    );
  }
}
