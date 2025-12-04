import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:estacionamiento/utils/session.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controladores para obtener textos del input
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Instancia de Supabase
  final supabase = Supabase.instance.client;

  bool loading = false;
  bool obscure = true;
  String? errorMsg;

  // -----------------------------------------------------------
  // VALIDAR FORMATO DE CORREO
  // -----------------------------------------------------------
  String? validarCorreo(String email) {
    // Expresión regular para verificar formato válido
    final regex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(email)) {
      return "Correo inválido, revisa el formato";
    }
    return null;
  }

  // -----------------------------------------------------------
  // VALIDACIÓN FUERTE DE CONTRASEÑA
  // -----------------------------------------------------------
  String? validarContrasenaLogin(String password) {
    if (password.length < 8) {
      return "La contraseña debe tener al menos 8 caracteres";
    }

    // Verificar que inicie con mayúscula
    if (!RegExp(r'^[A-Z]').hasMatch(password)) {
      return "La primera letra debe ser mayúscula";
    }

    // Verificar minúsculas, números y caracteres especiales permitidos
    if (!RegExp(r'^[A-Z][a-z0-9!@#\$&*~]+$').hasMatch(password)) {
      return "Debe contener minúsculas, números o caracteres especiales válidos";
    }

    return null;
  }

  // -----------------------------------------------------------
  // FUNCIÓN PRINCIPAL DE LOGIN
  // -----------------------------------------------------------
  Future<void> login() async {
    setState(() {
      loading = true;
      errorMsg = null;
    });

    try {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      // Validar correo
      final emailError = validarCorreo(email);
      if (emailError != null) {
        setState(() {
          errorMsg = emailError;
          loading = false;
        });
        return;
      }

      // Validar contraseña
      final passError = validarContrasenaLogin(password);
      if (passError != null) {
        setState(() {
          errorMsg = passError;
          loading = false;
        });
        return;
      }

      // -----------------------------------------------------------
      // BUSCAR USUARIO EN SUPABASE
      // -----------------------------------------------------------
      final response = await supabase
          .from("Usuarios")
          .select()
          .eq("Email", email)
          .maybeSingle();

      // Si el correo no existe
      if (response == null) {
        setState(() => errorMsg = "Correo no encontrado");
        return;
      }

      final storedHash = response["Contrasenia"];

      // Si no tiene contraseña guardada en DB
      if (storedHash == null || storedHash.isEmpty) {
        setState(() => errorMsg = "El usuario no tiene contraseña registrada");
        return;
      }

      // -----------------------------------------------------------
      // VALIDAR CONTRASEÑA CON BCRYPT
      // -----------------------------------------------------------
      final isCorrect = BCrypt.checkpw(password, storedHash);

      if (!isCorrect) {
        setState(() => errorMsg = "Contraseña incorrecta");
        return;
      }

      // -----------------------------------------------------------
      // GUARDAR SESIÓN LOCALMENTE
      // -----------------------------------------------------------
      SessionManager.login(response);

      if (!mounted) return;

      // Redirigir al home
      Navigator.pushReplacementNamed(context, "/home");
    } catch (e) {
      setState(() => errorMsg = "Error inesperado: $e");
    } finally {
      setState(() => loading = false);
    }
  }

  // -----------------------------------------------------------
  // DISEÑO Y ESTRUCTURA DE LA PANTALLA
  // -----------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Ícono superior
              const Icon(
                Icons.lock_outline,
                size: 90,
                color: Colors.blueAccent,
              ),
              const SizedBox(height: 20),

              // Título
              const Text(
                "Bienvenido",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              // Subtítulo
              Text(
                "Inicia sesión para continuar",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),

              const SizedBox(height: 35),

              // -----------------------------------------------------------
              // INPUT DE CORREO
              // -----------------------------------------------------------
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Correo electrónico",
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // -----------------------------------------------------------
              // INPUT DE CONTRASEÑA
              // -----------------------------------------------------------
              TextField(
                controller: passwordController,
                obscureText: obscure,
                decoration: InputDecoration(
                  labelText: "Contraseña",
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.lock_outline),

                  // Mostrar/ocultar contraseña
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscure ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() => obscure = !obscure);
                    },
                  ),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // Mostrar errores
              if (errorMsg != null)
                Text(
                  errorMsg!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),

              const SizedBox(height: 25),

              // -----------------------------------------------------------
              // BOTÓN LOGIN
              // -----------------------------------------------------------
              ElevatedButton(
                onPressed: loading ? null : login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),

                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Iniciar Sesión",
                        style: TextStyle(fontSize: 18),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
