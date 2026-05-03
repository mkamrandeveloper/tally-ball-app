import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../widgets/common.dart';
import '../../utils/toast_utils.dart';
import '../../services/hardware_service.dart';
import '../../services/game_service.dart';

class HardwareConnectionScreen extends StatefulWidget {
  const HardwareConnectionScreen({super.key});

  @override
  State<HardwareConnectionScreen> createState() => _HardwareConnectionScreenState();
}

class _HardwareConnectionScreenState extends State<HardwareConnectionScreen> {
  final HardwareService _hardwareService = HardwareService();
  bool _isScanning = false;
  StreamSubscription<bool>? _scanSubscription;

  @override
  void initState() {
    super.initState();
    _scanSubscription = FlutterBluePlus.isScanning.listen((scanning) {
      if (mounted) setState(() => _isScanning = scanning);
    });
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    super.dispose();
  }

  void _scanForDevices() async {
    try {
      await _hardwareService.startScan();
    } catch (e) {
      if (mounted) TallyToast.showError(context, 'Bluetooth must be enabled to scan.');
    }
  }

  Future<void> _handleConnect(BluetoothDevice device) async {
    final gameService = context.read<GameService>();
    
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator(color: context.colors.precisionBlue)),
    );

    try {
      await _hardwareService.connectToDevice(device, gameService);
      if (mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connected to ${device.platformName.isNotEmpty ? device.platformName : "Target"}')),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        TallyToast.showError(context, 'Connection failed: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bgPrimary,
      appBar: AppBar(
        title: const Text('HARDWARE'),
        titleTextStyle: TallyTextStyles.heading2(context).copyWith(color: context.colors.precisionBlue),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('PAIR TARGETS', style: TallyTextStyles.heading1(context)),
            const SizedBox(height: 12),
            Text('Connect your Tally Ball physical targets via Bluetooth to start tracking scores.',
              style: TallyTextStyles.bodyMedium(context)),
            const SizedBox(height: 32),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.colors.precisionBlue25.withOpacity(0.2),
                    ),
                  ),
                  if (_isScanning)
                    SizedBox(
                      width: 130,
                      height: 130,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation(context.colors.precisionBlue),
                        backgroundColor: context.colors.precisionBlue25.withOpacity(0.3),
                      ),
                    ),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.colors.precisionBlue.withOpacity(0.1),
                    ),
                    child: Icon(_isScanning ? Icons.bluetooth_searching : Icons.bluetooth, 
                      size: 48, color: context.colors.precisionBlue),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('AVAILABLE DEVICES', style: TallyTextStyles.label(context).copyWith(letterSpacing: 2, color: context.colors.textPrimary)),
                if (_isScanning)
                  Text('SCANNING...', style: TallyTextStyles.label(context).copyWith(color: context.colors.optimisticYellow, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<List<ScanResult>>(
                stream: FlutterBluePlus.scanResults,
                initialData: const [],
                builder: (context, snapshot) {
                  final results = snapshot.data ?? [];
                  if (results.isEmpty && !_isScanning) {
                    return Center(
                      child: Text('No devices found. Ensure targets are powered on.', 
                        style: TallyTextStyles.bodySmall(context)),
                    );
                  }
                  return ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final device = results[index].device;
                      final name = device.platformName.isNotEmpty ? device.platformName : 'Unknown Target';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            color: context.colors.precisionBlue25.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: context.colors.precisionBlue.withOpacity(0.1)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: context.colors.precisionBlue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(Icons.gps_fixed, color: context.colors.precisionBlue, size: 20),
                                  ),
                                  const SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(name, style: TallyTextStyles.bodyLarge(context).copyWith(fontWeight: FontWeight.w700)),
                                      Text('RSSI: ${results[index].rssi} dBm', style: TallyTextStyles.bodySmall(context)),
                                    ],
                                  ),
                                ],
                              ),
                              TallyButton(
                                text: 'PAIR',
                                width: 80,
                                height: 36,
                                onPressed: () => _handleConnect(device),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            TallyButton(
              text: _isScanning ? 'STOP SCAN' : 'SCAN FOR TARGETS',
              icon: _isScanning ? Icons.stop : Icons.refresh,
              onPressed: _isScanning ? _hardwareService.stopScan : _scanForDevices,
            ),
          ],
        ),
      ),
    );
  }
}
