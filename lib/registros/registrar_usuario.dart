import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bcrypt/bcrypt.dart';

class RegistrarUsuarioPage extends StatefulWidget {
  const RegistrarUsuarioPage({super.key});

  @override
  State<RegistrarUsuarioPage> createState() => _RegistrarUsuarioPageState();
}

class _RegistrarUsuarioPageState extends State<RegistrarUsuarioPage> {
  final _formKey = GlobalKey<FormState>();

  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fechaController = TextEditingController();

  DateTime? _fechaSeleccionada;
  bool _loading = false;
  String? _errorMessage;

  bool _mostrarPassword = false; // 👁️ Estado del ojo

  final supabase = Supabase.instance.client;

  // Validación de contraseña
  String? validarContrasena(String password) {
    if (password.length < 8) {
      return "La contraseña debe tener al menos 8 caracteres";
    }
    if (!RegExp(r'^[A-Z]').hasMatch(password)) {
      return "La primera letra debe ser mayúscula";
    }
    if (!RegExp(r'^[A-Z][a-z0-9!@#\$&*~]*$').hasMatch(password)) {
      return "El resto deben ser minúsculas, números o signos válidos";
    }
    return null;
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final passError = validarContrasena(_passwordController.text.trim());
    if (passError != null) {
      setState(() => _errorMessage = passError);
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final nombre = _nombreController.text.trim();
      final apellido = _apellidoController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final fecha = _fechaController.text;

      final existingUser = await supabase
          .from('Usuarios')
          .select()
          .eq('Email', email)
          .maybeSingle();

      if (existingUser != null) {
        throw Exception("Este correo ya está registrado");
      }

      final hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());

      await supabase.from('Usuarios').insert({
        'Nombre': nombre,
        'Apellido': apellido,
        'Email': email,
        'Contrasenia': hashedPassword,
        'Fecha_Nac': fecha,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Usuario registrado correctamente")),
      );

      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll("Exception: ", "");
      });
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registrar usuario")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: "Nombre"),
                validator: (v) =>
                    v == null || v.isEmpty ? "Ingresa tu nombre" : null,
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: _apellidoController,
                decoration: const InputDecoration(labelText: "Apellido"),
                validator: (v) =>
                    v == null || v.isEmpty ? "Ingresa tu apellido" : null,
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Correo"),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) return "Ingresa tu correo";
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
                    return "Correo inválido";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              // 🔥 CONTRASEÑA CON OJO
              TextFormField(
                controller: _passwordController,
                obscureText: !_mostrarPassword,
                decoration: InputDecoration(
                  labelText: "Contraseña",
                  suffixIcon: IconButton(
                    icon: Icon(
                      _mostrarPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() => _mostrarPassword = !_mostrarPassword);
                    },
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return "Ingresa una contraseña";
                  return validarContrasena(v);
                },
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: _fechaController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: "Fecha de nacimiento",
                  suffixIcon: Icon(Icons.calendar_month),
                ),
                validator: (v) {
                  if (_fechaSeleccionada == null) {
                    return "Selecciona tu fecha de nacimiento";
                  }
                  return null;
                },
                onTap: () async {
                  FocusScope.of(context).unfocus();

                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime(2000),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );

                  if (picked != null) {
                    setState(() {
                      _fechaSeleccionada = picked;
                      _fechaController.text =
                          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                    });
                  }
                },
              ),

              const SizedBox(height: 20),

              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _loading ? null : _register,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 40,
                  ),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Registrar", style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
