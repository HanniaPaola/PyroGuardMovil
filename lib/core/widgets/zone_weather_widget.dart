import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../constants/app_colors.dart';
import 'skeleton_loader.dart';

class ZoneWeatherWidget extends StatefulWidget {
  final String zoneId;
  const ZoneWeatherWidget({super.key, required this.zoneId});

  @override
  State<ZoneWeatherWidget> createState() => _ZoneWeatherWidgetState();
}

class _ZoneWeatherWidgetState extends State<ZoneWeatherWidget> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _weatherData;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    try {
      final url = 'https://pyroguard.inode.cloud/ml/api/v1/zonas/${widget.zoneId}/clima';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _weatherData = json.decode(response.body);
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Error');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Clima no disponible';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Padding(
        padding: EdgeInsets.only(top: 4.0),
        child: SkeletonLoader(width: 100, height: 12),
      );
    }
    if (_error != null || _weatherData == null) {
      return Padding(
        padding: EdgeInsets.only(top: 4.0),
        child: Text(_error ?? '', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
      );
    }

    final temp = _weatherData!['temperatura_actual'];
    final hum = _weatherData!['humedad'];
    final wind = _weatherData!['viento'];

    return Padding(
      padding: EdgeInsets.only(top: 4.0),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.thermostat, size: 12, color: AppColors.fireGlow),
              SizedBox(width: 2),
              Text(temp.toString(), style: TextStyle(color: AppColors.cream, fontSize: 11)),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.water_drop, size: 12, color: Colors.blueAccent),
              SizedBox(width: 2),
              Text(hum.toString(), style: TextStyle(color: AppColors.cream, fontSize: 11)),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.air, size: 12, color: Colors.white70),
              SizedBox(width: 2),
              Text(wind.toString(), style: TextStyle(color: AppColors.cream, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}
