import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import 'package:permission_handler/permission_handler.dart';

class BluetoothService {
  fbp.BluetoothDevice? connectedDevice;

  Future<void> startScan() async {
    // Запрос разрешений
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();

    if (await Permission.bluetoothScan.isGranted && await Permission.bluetoothConnect.isGranted) {
      try {
        await fbp.FlutterBluePlus.startScan(timeout: Duration(seconds: 4));
        print('Сканирование начато');
      } catch (e) {
        print('Ошибка при запуске сканирования: $e');
      }
    } else {
      print('Разрешения Bluetooth не предоставлены');
    }
  }

  Stream<List<fbp.ScanResult>> get scanResults => fbp.FlutterBluePlus.scanResults;

  Future<void> connectToDevice(fbp.BluetoothDevice device) async {
    try {
      await device.connect();
      connectedDevice = device;
      print('Подключено к ${device.name}');
    } catch (e) {
      print('Ошибка подключения: $e');
    }
  }

  Future<void> disconnect() async {
    if (connectedDevice != null) {
      await connectedDevice!.disconnect();
      connectedDevice = null;
      print('Отключено');
    }
  }
}