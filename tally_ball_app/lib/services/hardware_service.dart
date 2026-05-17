import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter/foundation.dart';
import '../models/game_models.dart';
import 'game_service.dart';

class HardwareService {
  // Singleton pattern
  static final HardwareService _instance = HardwareService._internal();
  factory HardwareService() => _instance;
  HardwareService._internal();

  BluetoothDevice? _connectedDevice;

  StreamSubscription<BluetoothConnectionState>? _stateSubscription;
  
  // Custom UUIDs - Replace these with your actual hardware UUIDs
  static const String serviceUuid = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  static const String characteristicUuid = "beb5483e-36e1-4688-b7f5-ea07361b26a8";

  BluetoothDevice? get connectedDevice => _connectedDevice;

  /// Start scanning for Tally Ball targets
  Future<void> startScan() async {
    // Check if Bluetooth is available
    if (await FlutterBluePlus.isSupported == false) {
      debugPrint("Bluetooth not supported by this device");
      return;
    }

    // Wait for Bluetooth to be turned on
    await FlutterBluePlus.adapterState
        .where((val) => val == BluetoothAdapterState.on)
        .first;

    await FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 15),
      withKeywords: ["Tally", "Target"], // Only show devices with these names
    );
  }

  /// Stop scanning
  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
  }

  /// Connect to a specific device
  Future<void> connectToDevice(BluetoothDevice device, GameService gameService) async {
    try {
      await device.connect();
      _connectedDevice = device;

      _stateSubscription?.cancel();
      _stateSubscription = device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
          _connectedDevice = null;
          debugPrint("Device disconnected");
        }
      });

      // Discover services
      List<BluetoothService> services = await device.discoverServices();
      for (var service in services) {
        // Look for our specific service
        if (service.uuid.toString().toLowerCase() == serviceUuid.toLowerCase()) {
          for (var characteristic in service.characteristics) {
            if (characteristic.uuid.toString().toLowerCase() == characteristicUuid.toLowerCase()) {
              // Enable notifications
              await characteristic.setNotifyValue(true);
              characteristic.lastValueStream.listen((value) {
                _handleHitData(value, gameService);
              });
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Error connecting: $e");
    }
  }

  /// Handle incoming hit data from the hardware
  void _handleHitData(List<int> data, GameService gameService) {
    if (data.isEmpty) return;

    // Example Protocol:
    // Byte 0: Target ID (1, 2, 3...)
    // Byte 1: Force/Power (0-255)
    
    int targetId = data[0];
    int powerValue = data.length > 1 ? data[1] : 100;
    
    // Map targetId to a Zone
    TargetZone zone = TargetZone.center;
    if (targetId == 1) zone = TargetZone.topRight;
    if (targetId == 2) zone = TargetZone.topLeft;
    if (targetId == 3) zone = TargetZone.bottomRight;
    if (targetId == 4) zone = TargetZone.bottomLeft;

    gameService.recordHardwareHit(zone, powerValue.toDouble());
  }

  /// Disconnect current device
  Future<void> disconnect() async {
    await _connectedDevice?.disconnect();
    _connectedDevice = null;
    _stateSubscription?.cancel();
  }
}
