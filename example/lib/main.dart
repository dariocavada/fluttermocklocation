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
  String _positionUpdated = '';
  String _errorString = '';
  final _fluttermocklocationPlugin = Fluttermocklocation();

  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lngController = TextEditingController();
  final TextEditingController _altitudeController = TextEditingController();
  final TextEditingController _delayController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initPlatformState();

// Ascolta gli aggiornamenti della posizione
    _fluttermocklocationPlugin.locationUpdates.listen((locationData) {
      // Get the current timestamp
      final DateTime now = DateTime.now();
      final String formattedTimestamp =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} "
          "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";

      // Format the position string
      final String positionString = 'latitude: ${locationData['latitude']}\n'
          'longitude: ${locationData['longitude']}\n'
          'altitude: ${locationData['altitude']}\n'
          'timestamp: $formattedTimestamp';

      // Update the position with the formatted string
      setState(() {
        _positionUpdated = positionString;
      });

      print(_positionUpdated);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    try {
      platformVersion = await _fluttermocklocationPlugin.getPlatformVersion() ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  void _updateLocation() async {
    try {
      setState(() {
        _error = false;
        _errorString = '';
      });

      final double latitude = double.parse(_latController.text);
      final double longitude = double.parse(_lngController.text);
      final double altitude = double.parse(_altitudeController.text);
      final int delay =
          int.tryParse(_delayController.text) ?? 5000; // Default to 5000 ms

      try {
        await Fluttermocklocation().updateMockLocation(
          latitude,
          longitude,
          altitude: altitude,
          delay: delay,
        );
        print(
            "Mock location updated: $latitude, $longitude, $altitude with delay $delay ms");
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
        _errorString = 'Invalid latitude, longitude, or delay.';
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
              TextField(
                controller: _delayController,
                decoration: const InputDecoration(labelText: 'Delay (ms)'),
                keyboardType: TextInputType.number,
              ),
              ElevatedButton(
                onPressed: _updateLocation,
                child: const Text('Set Mock Location'),
              ),
              const SizedBox(
                height: 20,
              ),
              (_positionUpdated != '')
                  ? Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          _positionUpdated,
                        ),
                      ),
                    )
                  : Container(),
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
