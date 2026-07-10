import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import '../constants/app_colors.dart';
import 'skeleton_loader.dart';

class CustomPolygonMap extends StatefulWidget {
  final double height;

  const CustomPolygonMap({super.key, this.height = 280});

  @override
  State<CustomPolygonMap> createState() => _CustomPolygonMapState();
}

class _CustomPolygonMapState extends State<CustomPolygonMap> {
  List<Polygon> _polygons = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchZones();
  }

  Future<void> _fetchZones() async {
    try {
      final responses = await Future.wait([
        http.get(Uri.parse('https://pyroguard.inode.cloud/ml/api/v1/zonas/')),
        http.get(Uri.parse('https://pyroguard.inode.cloud/ml/api/v1/zonas/riesgo-publico')),
      ]);

      if (responses[0].statusCode == 200 && responses[1].statusCode == 200) {
        final List<dynamic> geojsonData = json.decode(responses[0].body);
        final List<dynamic> riskData = json.decode(responses[1].body);

        // Crear mapa de riesgos por nombre
        final Map<String, String> riskMap = {};
        for (var item in riskData) {
          riskMap[item['nombre'] as String] = item['nivel_riesgo'] as String;
        }

        final List<Polygon> parsedPolygons = [];

        for (var item in geojsonData) {
          final geojsonStr = item['geojson'] as String?;
          final name = item['nombre'] as String? ?? '';
          final risk = riskMap[name] ?? 'Desconocido';

          if (geojsonStr != null) {
            final geojson = json.decode(geojsonStr);
            
            if (geojson['type'] == 'Polygon') {
              final coordinates = geojson['coordinates'][0] as List;
              parsedPolygons.add(_createPolygon(coordinates, name, risk));
            } else if (geojson['type'] == 'MultiPolygon') {
              for (var poly in geojson['coordinates']) {
                final coordinates = poly[0] as List;
                parsedPolygons.add(_createPolygon(coordinates, name, risk));
              }
            }
          }
        }

        if (mounted) {
          setState(() {
            _polygons = parsedPolygons;
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load zones or risks');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  Color _getColorForRisk(String risk) {
    switch (risk.toLowerCase()) {
      case 'bajo':
      case 'sin riesgo':
        return AppColors.riskLow;
      case 'medio':
      case 'precaución':
        return AppColors.riskMedium;
      case 'alto':
      case 'alerta':
        return AppColors.riskHigh;
      case 'crítico':
      case 'peligro':
        return AppColors.riskCritical;
      default:
        return AppColors.fireMid; // fallback
    }
  }

  Polygon _createPolygon(List coordinates, dynamic name, String risk) {
    final List<LatLng> points = coordinates.map((coord) {
      return LatLng((coord[1] as num).toDouble(), (coord[0] as num).toDouble());
    }).toList();

    final Color riskColor = _getColorForRisk(risk);

    return Polygon(
      points: points,
      color: riskColor.withValues(alpha: 0.4),
      borderColor: riskColor,
      borderStrokeWidth: 2,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: _isLoading 
          ? const SkeletonLoader(width: double.infinity, height: double.infinity, borderRadius: 0)
          : _hasError 
              ? Center(child: Text('Error cargando mapa', style: TextStyle(color: AppColors.textMuted)))
              : FlutterMap(
                  options: MapOptions(
                    initialCenter: _polygons.isNotEmpty && _polygons.first.points.isNotEmpty 
                        ? _polygons.first.points.first 
                        : const LatLng(15.75, -92.73),
                    initialZoom: 9.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c', 'd'],
                    ),
                    PolygonLayer(
                      polygons: _polygons,
                    ),
                  ],
                ),
    );
  }
}
