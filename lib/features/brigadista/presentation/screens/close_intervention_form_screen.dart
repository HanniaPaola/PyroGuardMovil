import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/brigadista_provider.dart';
import '../../../../core/constants/app_colors.dart';

class CloseInterventionFormScreen extends StatefulWidget {
  const CloseInterventionFormScreen({super.key});

  @override
  State<CloseInterventionFormScreen> createState() =>
      _CloseInterventionFormScreenState();
}

class _CloseInterventionFormScreenState
    extends State<CloseInterventionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedResult;
  final TextEditingController _notesController = TextEditingController();

  final List<String> _resultOptions = [
    'Controlado',
    'Extinguido',
    'Contenido',
    'Falsa Alarma',
    'Requiere más recursos',
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final provider = context.read<BrigadistaProvider>();

      // El backend solo acepta "Completada" en el estado final.
      // Así que anexamos el resultado visual ("Extinguido", etc.) a las observaciones.
      final String estadoBackend = 'Completada';
      final String notasAnexadas =
          '[${_selectedResult!}] ${_notesController.text.trim()}'.trim();

      final success = await provider.closeActiveIntervention(
        result: estadoBackend,
        notes: notasAnexadas,
      );

      if (!mounted) return;

      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Intervención finalizada y reporte enviado.'),
            backgroundColor: Colors.green.shade700,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al enviar el reporte. Inténtalo de nuevo.'),
            backgroundColor: Colors.red.shade900,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BrigadistaProvider>();
    final zoneName = provider.activeInterventionZoneName ?? 'Zona Desconocida';

    return Scaffold(
      backgroundColor: AppColors.smoke,
      appBar: AppBar(
        backgroundColor: AppColors.smoke,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Cierre de Intervención',
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(20),
            children: [
              Text(
                'Zona: $zoneName',
                style: TextStyle(
                  color: AppColors.fireGlow,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 24),

              Text(
                'Resultado de la operación *',
                style: TextStyle(
                  color: AppColors.cream,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                dropdownColor: AppColors.ash,
                style: TextStyle(color: AppColors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.ash,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                initialValue: _selectedResult,
                hint: Text(
                  'Selecciona el resultado',
                  style: TextStyle(color: AppColors.textMuted),
                ),
                items: _resultOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedResult = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor selecciona un resultado';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),

              Text(
                'Observaciones y reporte final',
                style: TextStyle(
                  color: AppColors.cream,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                maxLines: 5,
                style: TextStyle(color: AppColors.white),
                decoration: InputDecoration(
                  hintText:
                      'Describe el estado final, áreas afectadas y cualquier novedad...',
                  hintStyle: TextStyle(color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.ash,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 40),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.fireGlow,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: provider.closingIntervention ? null : _submit,
                child: provider.closingIntervention
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: AppColors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'FINALIZAR INTERVENCIÓN',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
