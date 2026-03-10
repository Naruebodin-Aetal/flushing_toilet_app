import 'dart:convert';
import 'package:http/http.dart' as http;

class FlushingService {
  static const String controlUrl =
      'https://api.netpie.io/v2/device/message?topic=lab_ict_kps/flush/value';/*แก้ตรงนี้ */
  static const String statusUrl = 'https://api.netpie.io/v2/device/shadow/data';/*แก้ตรงนี้ */

  // สำหรับการควบคุมหลอดไฟ (setLedStatus)
  static const String controlClientId = '63654b3c-3aed-4575-bdea-6ae340dd9568'; // of Mobile App
  static const String controlToken = 'uYFNZRPa6KAnQgS1Uvbp9kJYsQZ2Pk5L'; // of Mobile App

  // สำหรับการอ่านสถานะ
  static const String statusClientId = '8ad22b92-426b-4dc0-a575-2d36aeedee39';  // of ESP32
  static const String statusToken = 'm2EKkWEMDBuqkHW3E6WkhjTSUkjwQ8hi';  // of ESP32

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
      return data['data']['isFlushing'] == 0;/*แก้ตรงนี้ */
    } else {
      throw Exception('Failed to fetch Flushing status');
    }
  }

  Future<void> setFlushingStatus(bool isFlushing) async {
    final payload = json.encode({
      'data': {"isFlushing": isFlushing ? 1 : 0},/*แก้ตรงนี้ */
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