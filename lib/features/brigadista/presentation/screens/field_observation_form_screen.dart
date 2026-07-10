import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/brigadista_provider.dart';
import '../widgets/observation_form_field.dart';
import '../../domain/entities/field_observation.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/section_header.dart';
import 'package:geolocator/geolocator.dart';

/// HU03: formulario de observación técnica en campo. Captura coordenadas
/// GPS, texto libre y opciones predefinidas; soporta cola offline.
class FieldObservationFormScreen extends StatefulWidget {
  const FieldObservationFormScreen({super.key});

  @override
  State<FieldObservationFormScreen> createState() =>
      _FieldObservationFormScreenState();
}

class _FieldObservationFormScreenState
    extends State<FieldObservationFormScreen> {
  final _notesController = TextEditingController();
  final Set<String> _selectedOptions = {};

  double? _latitude;
  double? _longitude;
  bool _locatingGps = true;

  String? _selectedZoneId;

  final List<String> _options = [
    'Acceso vehicular',
    'Sin acceso vehicular',
    'Agua cercana',
    'Sin agua cercana',
    'Vegetación seca',
    'Terreno escarpado',
    'Viento fuerte',
    'Presencia de fauna',
  ];

  @override
  void initState() {
    super.initState();
    _captureGpsLocation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BrigadistaProvider>().loadSimpleZones();
    });
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
        _latitude = position.latitude;
        _longitude = position.longitude;
        _locatingGps = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _locatingGps = false;
        // Coordenadas simuladas de respaldo
        _latitude = 16.789;
        _longitude = -93.654;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: AppColors.riskCritical,
        ),
      );
    }
  }

  void _toggleOption(String option) {
    setState(() {
      if (_selectedOptions.contains(option)) {
        _selectedOptions.remove(option);
      } else {
        _selectedOptions.add(option);
      }
    });
  }

  Future<void> _submit() async {
    if (_latitude == null || _longitude == null) return;
    if (_selectedZoneId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selecciona una zona primero')),
      );
      return;
    }

    final observation = FieldObservation(
      id: 'obs-${DateTime.now().millisecondsSinceEpoch}',
      zoneId: _selectedZoneId!,
      latitude: _latitude!,
      longitude: _longitude!,
      conditionNotes: _notesController.text.trim(),
      selectedOptions: _selectedOptions.toList(),
      createdAt: DateTime.now(),
    );

    final provider = context.read<BrigadistaProvider>();
    final success = await provider.submitObservation(observation);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.ash,
        content: Text(
          success
              ? 'Observación enviada correctamente.'
              : 'No se pudo guardar la observación. Intenta de nuevo.',
          style: TextStyle(color: AppColors.cream),
        ),
      ),
    );

    if (success) Navigator.pop(context);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BrigadistaProvider>();

    return Scaffold(
      backgroundColor: AppColors.smoke,
      appBar: AppBar(
        title: Text('Nueva Observación'),
        backgroundColor: AppColors.smoke,
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          SectionHeader(
            tag: 'Registro de campo',
            title: 'Observación técnica',
            subtitle:
                'Documenta condiciones, accesos y recursos disponibles en tu ubicación actual.',
          ),
          SizedBox(height: 20),

          // Selector de Zona
          Text(
            'ZONA A REPORTAR',
            style: TextStyle(
              color: AppColors.fireMid,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 10),
          provider.loadingSimpleZones
              ? CircularProgressIndicator(color: AppColors.fireMid)
              : DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: _selectedZoneId,
                  dropdownColor: AppColors.ash,
                  style: TextStyle(color: AppColors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.ash,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: provider.simpleZones.map((z) {
                    return DropdownMenuItem<String>(
                      value: z.id,
                      child: Text(
                        z.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedZoneId = val;
                    });
                  },
                  hint: Text('Selecciona una zona', style: TextStyle(color: AppColors.textMuted)),
                ),

          SizedBox(height: 20),

          // GPS
          Container(
            padding: EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.ash,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.fireMid.withValues(alpha: 0.12)),
            ),
            child: Row(
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
                        ? 'Obteniendo coordenadas GPS...'
                        : 'Ubicación capturada: ${_latitude!.toStringAsFixed(4)}, ${_longitude!.toStringAsFixed(4)}',
                    style: TextStyle(
                      color: AppColors.textDim,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20),
          Text(
            'CONDICIONES OBSERVADAS',
            style: TextStyle(
              color: AppColors.fireMid,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _options.map((opt) {
              return ObservationOptionChip(
                label: opt,
                selected: _selectedOptions.contains(opt),
                onTap: () => _toggleOption(opt),
              );
            }).toList(),
          ),

          SizedBox(height: 20),
          Text(
            'NOTAS ADICIONALES',
            style: TextStyle(
              color: AppColors.fireMid,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 10),
          TextField(
            controller: _notesController,
            maxLines: 5,
            style: TextStyle(color: AppColors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Describe lo que observas en el terreno...',
              hintStyle: TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
              ),
              filled: true,
              fillColor: AppColors.ash,
              contentPadding: EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.textMuted.withValues(alpha: 0.15),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.fireMid,
                  width: 1.4,
                ),
              ),
            ),
          ),

          SizedBox(height: 28),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: (_locatingGps || provider.submittingObservation)
                  ? null
                  : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.fireMid,
                disabledBackgroundColor: AppColors.fireMid.withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: provider.submittingObservation
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: AppColors.white,
                      ),
                    )
                  : Text(
                      'Guardar observación',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
          SizedBox(height: 12),
        ],
      ),
    );
  }
}
