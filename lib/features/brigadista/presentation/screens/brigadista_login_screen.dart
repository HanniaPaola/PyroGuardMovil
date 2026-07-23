import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/input_sanitizer.dart';
import '../providers/auth_provider.dart';
import 'brigadista_home_screen.dart';

/// Pantalla de inicio de sesión exclusiva para brigadistas de campo.
/// Conectada a POST /v1/auth/login vía AuthProvider.
class BrigadistaLoginScreen extends StatefulWidget {
  const BrigadistaLoginScreen({super.key});

  @override
  State<BrigadistaLoginScreen> createState() => _BrigadistaLoginScreenState();
}

class _BrigadistaLoginScreenState extends State<BrigadistaLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();

    // 8. Sanitización de entrada (Limpieza)
    final sanitizedEmail = InputSanitizer.cleanString(_emailController.text);

    final success = await authProvider.login(
      email: sanitizedEmail,
      password: _passwordController
          .text, // La contraseña no se sanitiza igual para no alterar hashes, pero se valida su formato en el TextFormField.
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => BrigadistaHomeScreen()),
      );
    }
    // Si falla, el error se muestra reactivamente vía authProvider.errorMessage
    // (consumido en el build de abajo). No hace falta nada más aquí.
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.smoke,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 28, vertical: 40),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo / encabezado
                  Container(
                    width: 84,
                    height: 84,
                    margin: EdgeInsets.only(bottom: 24),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.fireMid, AppColors.ember],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.fireMid.withValues(alpha: 0.35),
                          blurRadius: 24,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Text('🧑‍🚒', style: TextStyle(fontSize: 38)),
                  ),

                  Center(
                    child: Text(
                      'Acceso Brigadista',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(height: 6),
                  Center(
                    child: Text(
                      'PyroGuard AI · Módulo de campo',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ),

                  SizedBox(height: 36),

                  // Campo: correo
                  _FieldLabel('CORREO ELECTRÓNICO'),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    style: TextStyle(color: AppColors.white),
                    decoration: _inputDecoration(
                      hint: 'correo@ejemplo.com',
                      icon: Icons.email_outlined,
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Ingresa tu correo';
                      }
                      final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                      if (!emailRegex.hasMatch(v.trim())) {
                        return 'Ingresa un correo válido';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 18),

                  // Campo: contraseña
                  _FieldLabel('CONTRASEÑA'),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: TextStyle(color: AppColors.white),
                    decoration: _inputDecoration(
                      hint: '••••••••',
                      icon: Icons.lock_outline,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.textMuted,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Ingresa tu contraseña';
                      }
                      // 5. Validación de patrones y reglas específicas
                      if (v.length < 6) {
                        return 'La contraseña debe tener al menos 6 caracteres';
                      }
                      if (!v.contains(RegExp(r'[a-zA-Z]')) ||
                          !v.contains(RegExp(r'[0-9]'))) {
                        return 'Debe contener letras y números';
                      }
                      return null;
                    },
                  ),

                  if (authProvider.errorMessage != null) ...[
                    SizedBox(height: 14),
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
                        authProvider.errorMessage!,
                        style: TextStyle(
                          color: AppColors.riskCritical,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],

                  SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        '¿Olvidaste tu contraseña?',
                        style: TextStyle(
                          color: AppColors.textDim,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 18),

                  // Botón ingresar
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: authProvider.isLoading ? null : _handleLogin,
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
                      child: authProvider.isLoading
                          ? SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: AppColors.white,
                              ),
                            )
                          : Text(
                              'Ingresar',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),

                  SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: AppColors.textMuted.withValues(alpha: 0.2),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'Acceso restringido a personal Conafor',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: AppColors.textMuted.withValues(alpha: 0.2),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
      prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.ash,
      contentPadding: EdgeInsets.symmetric(vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppColors.textMuted.withValues(alpha: 0.15),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppColors.textMuted.withValues(alpha: 0.15),
        ),
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
