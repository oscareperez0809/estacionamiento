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
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final supabase = Supabase.instance.client;

  bool loading = false;
  bool obscure = true;
  String? errorMsg;

  Future<void> login() async {
    setState(() {
      loading = true;
      errorMsg = null;
    });

    try {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      // BUSCAR USUARIO
      final response = await supabase
          .from("Usuarios")
          .select()
          .eq("Email", email)
          .maybeSingle();

      if (response == null) {
        setState(() => errorMsg = "Correo no encontrado");
        return;
      }

      final storedHash = response["Contrasenia"];

      if (storedHash == null || storedHash.isEmpty) {
        setState(() => errorMsg = "El usuario no tiene contraseña registrada");
        return;
      }

      // VALIDACIÓN BCRYPT
      final isCorrect = BCrypt.checkpw(password, storedHash);

      if (!isCorrect) {
        setState(() => errorMsg = "Contraseña incorrecta");
        return;
      }

      // GUARDAR SESIÓN
      SessionManager.login(response);

      if (!mounted) return;

      Navigator.pushReplacementNamed(context, "/home");
    } catch (e) {
      setState(() => errorMsg = "Error: $e");
    } finally {
      setState(() => loading = false);
    }
  }

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
              const Icon(
                Icons.lock_outline,
                size: 90,
                color: Colors.blueAccent,
              ),
              const SizedBox(height: 20),

              const Text(
                "Bienvenido",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              Text(
                "Inicia sesión para continuar",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),

              const SizedBox(height: 35),

              // EMAIL
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

              // PASSWORD
              TextField(
                controller: passwordController,
                obscureText: obscure,
                decoration: InputDecoration(
                  labelText: "Contraseña",
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscure ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        obscure = !obscure;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              if (errorMsg != null)
                Text(
                  errorMsg!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),

              const SizedBox(height: 25),

              // BOTÓN LOGIN
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
