import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/citizen_report_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/section_header.dart';
import 'citizen_report_success_screen.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

/// Formulario público (sin autenticación) para que cualquier ciudadano
/// reporte un foco de riesgo o incendio.
/// Conectado a POST /v1/ciudadano/reportes.
class CitizenReportFormScreen extends StatefulWidget {
  const CitizenReportFormScreen({super.key});

  @override
  State<CitizenReportFormScreen> createState() =>
      _CitizenReportFormScreenState();
}

class _CitizenReportFormScreenState extends State<CitizenReportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  File? _pickedImage;
  final _imagePicker = ImagePicker();

  bool _locatingGps = true;

  @override
  void initState() {
    super.initState();
    _captureGpsLocation();
  }

  Future<void> _captureGpsLocation() async {
    setState(() => _locatingGps = true);
    
    bool serviceEnabled;
    LocationPermission permission;

    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Servicios de ubicación desactivados.');
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permisos de ubicación denegados.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Permisos permanentemente denegados.');
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      
      if (!mounted) return;
      setState(() {
        _latitudeController.text = position.latitude.toString();
        _longitudeController.text = position.longitude.toString();
        _locatingGps = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _locatingGps = false;
        // Fallback default coordinates
        _latitudeController.text = '16.7569';
        _longitudeController.text = '-93.1292';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: AppColors.riskCritical,
        ),
      );
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _imagePicker.pickImage(source: source, imageQuality: 70);
      if (picked != null) {
        setState(() {
          _pickedImage = File(picked.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo acceder a la imagen.')),
      );
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<CitizenReportProvider>();

    String? finalPhotoUrl;

    if (_pickedImage != null) {
      finalPhotoUrl = _pickedImage!.path;
    }

    final success = await provider.submit(
      description: _descriptionController.text.trim(),
      latitude: double.parse(_latitudeController.text),
      longitude: double.parse(_longitudeController.text),
      photoUrl: finalPhotoUrl,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              CitizenReportSuccessScreen(report: provider.lastReport!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CitizenReportProvider>();

    return Scaffold(
      backgroundColor: AppColors.smoke,
      appBar: AppBar(
        title: Text('Reportar Incendio'),
        backgroundColor: AppColors.smoke,
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          SectionHeader(
            tag: 'Reporte ciudadano',
            title: 'Avísanos lo que ves',
            subtitle:
                'Tu reporte ayuda a las brigadas a actuar más rápido. No necesitas una cuenta para enviarlo.',
          ),
          SizedBox(height: 24),

          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Ubicación (GPS)
                Container(
                  padding: EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.ash,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.fireMid.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            _locatingGps ? Icons.gps_not_fixed : Icons.gps_fixed,
                            color: _locatingGps
                                ? AppColors.textMuted
                                : AppColors.fireGlow,
                            size: 20,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _locatingGps
                                  ? 'Obteniendo tu ubicación...'
                                  : 'Ubicación: ${_latitudeController.text}, ${_longitudeController.text}',
                              style: TextStyle(
                                color: AppColors.textDim,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (!_locatingGps && _latitudeController.text.isNotEmpty)
                        Container(
                          height: 150,
                          margin: EdgeInsets.only(top: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.fireMid.withValues(alpha: 0.12)),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: FlutterMap(
                            options: MapOptions(
                              initialCenter: LatLng(
                                double.parse(_latitudeController.text),
                                double.parse(_longitudeController.text),
                              ),
                              initialZoom: 15.0,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
                                subdomains: ['a', 'b', 'c', 'd'],
                              ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: LatLng(
                                      double.parse(_latitudeController.text),
                                      double.parse(_longitudeController.text),
                                    ),
                                    child: Icon(Icons.location_on, color: AppColors.riskCritical, size: 40),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                SizedBox(height: 20),
                _FieldLabel('¿QUÉ ESTÁS VIENDO?'),
                SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 5,
                  style: TextStyle(color: AppColors.white, fontSize: 14),
                  decoration: _inputDecoration(
                    hint:
                        'Ej. Humo denso cerca del camino a la reserva, parece avanzar rápido...',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Describe lo que observas';
                    }
                    if (v.trim().length < 10) {
                      return 'Agrega un poco más de detalle (mín. 10 caracteres)';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 20),
                _FieldLabel('FOTO (OPCIONAL)'),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.camera),
                        icon: Icon(Icons.camera_alt, size: 18, color: AppColors.white),
                        label: Text('Tomar Foto', style: TextStyle(color: AppColors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.ash,
                          side: BorderSide(color: AppColors.fireMid.withValues(alpha: 0.5)),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        icon: Icon(Icons.photo_library, size: 18, color: AppColors.white),
                        label: Text('Galería', style: TextStyle(color: AppColors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.ash,
                          side: BorderSide(color: AppColors.fireMid.withValues(alpha: 0.5)),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_pickedImage != null)
                  Container(
                    margin: EdgeInsets.only(top: 12),
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.ash,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.fireMid.withValues(alpha: 0.15)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(_pickedImage!, fit: BoxFit.cover),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () => setState(() => _pickedImage = null),
                            child: Container(
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.close, color: Colors.white, size: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                if (provider.errorMessage != null) ...[
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.riskCritical.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.riskCritical.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      provider.errorMessage!,
                      style: TextStyle(
                        color: AppColors.riskCritical,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],

                SizedBox(height: 28),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: (_locatingGps || provider.isLoading)
                        ? null
                        : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.fireMid,
                      disabledBackgroundColor: AppColors.fireMid.withValues(
                        alpha: 0.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: provider.isLoading
                        ? SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: AppColors.white,
                            ),
                          )
                        : Text(
                            'Enviar reporte',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),

                SizedBox(height: 14),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.fireMid.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 15,
                        color: AppColors.textMuted,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Si el peligro es inminente, llama primero al 911.',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13),
      filled: true,
      fillColor: AppColors.ash,
      contentPadding: EdgeInsets.all(14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.textMuted.withValues(alpha: 0.15)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.textMuted.withValues(alpha: 0.15)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.fireMid, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.riskCritical),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.riskCritical, width: 1.4),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: AppColors.fireMid,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1,
      ),
    );
  }
}
