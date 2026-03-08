import 'dart:convert';
import 'package:http/http.dart' as http;

class FlushingService {
  static const String controlUrl =
      'https://api.netpie.io/v2/device/message?topic=home/device_control/H';/*แก้ตรงนี้ */
  static const String statusUrl = 'https://api.netpie.io/v2/device/shadow/data';/*แก้ตรงนี้ */

  // สำหรับการควบคุมหลอดไฟ (setLedStatus)
  static const String controlClientId = ''; // of Mobile App
  static const String controlToken = ''; // of Mobile App

  // สำหรับการอ่านสถานะหลอดไฟ (getLedStatus)
  static const String statusClientId = '';  // of ESP32
  static const String statusToken = '';  // of ESP32

  Map<String, String> get _controlHeaders => {
    'Content-Type': 'application/json',
    'Authorization': 'Device $controlClientId:$controlToken',
  };

  Map<String, String> get _statusHeaders => {
    'Content-Type': 'application/json',
    'Authorization': 'Device $statusClientId:$statusToken',
  };

  Future<bool> getFlushingStatus() async {
    final response = await http.get(
      Uri.parse(statusUrl),
      headers: _statusHeaders,
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data']['led1'] == 1;/*แก้ตรงนี้ */
    } else {
      throw Exception('Failed to fetch Flushing status');
    }
  }

  Future<void> setFlushingStatus(String type,bool isOn) async {
    final payload = json.encode({
      'data': {type: isOn ? 1 : 0},/*แก้ตรงนี้ */
    });
    final response = await http.put(
      Uri.parse(controlUrl),
      headers: _controlHeaders,
      body: payload,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to send Flushing command');
    }
  }
}