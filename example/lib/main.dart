import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:fluttermocklocation/fluttermocklocation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  bool _error = false;
  String _errorString = '';
  final _fluttermocklocationPlugin = Fluttermocklocation();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    // Start the timer to call _updateLocation every second
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer t) => _updateLocation(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion = await _fluttermocklocationPlugin.getPlatformVersion() ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lngController = TextEditingController();
  final TextEditingController _altitudeController = TextEditingController();

  void _updateLocation() async {
    try {
      setState(() {
        _error = false;
        _errorString = '';
      });

      final double latitude = double.parse(_latController.text);
      final double longitude = double.parse(_lngController.text);
      final double altitude = double.parse(_altitudeController.text);
      try {
        await Fluttermocklocation()
            .updateMockLocation(latitude, longitude, altitude: altitude);
        print("Mock location updated: $latitude, $longitude, $altitude");
      } catch (e) {
        print("Error updating the location: $e");
        setState(() {
          _errorString =
              'To use this application, please enable Developer Options on your Android device.\n\nWithin Developer Options select\n\n"Select mock location app"\n\nand choose this app.';
          _error = true;
        });
      }
    } catch (e) {
      setState(() {
        _errorString = 'Invalid latitude or longitude.';
        _error = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Mock Location'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Center(
                child: Text('Running on: $_platformVersion\n'),
              ),
              TextField(
                controller: _latController,
                decoration: const InputDecoration(labelText: 'Latitude'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _lngController,
                decoration: const InputDecoration(labelText: 'Longitude'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _altitudeController,
                decoration: const InputDecoration(labelText: 'Altitude'),
                keyboardType: TextInputType.number,
              ),
              ElevatedButton(
                onPressed: _updateLocation,
                child: const Text('Set Mock Location'),
              ),
              const SizedBox(
                height: 20,
              ),
              _error
                  ? Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          _errorString,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
