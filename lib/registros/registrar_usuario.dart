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

  final supabase = Supabase.instance.client;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final nombre = _nombreController.text.trim();
      final apellido = _apellidoController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final fecha = _fechaController.text; // ya está formateada

      // Verificar si el email ya existe
      final existingUser = await supabase
          .from('Usuarios')
          .select()
          .eq('Email', email)
          .maybeSingle();

      if (existingUser != null) {
        throw Exception("Este correo ya está registrado");
      }

      // Crear hash BCrypt
      final hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());

      // Insertar en Supabase
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

      Navigator.pop(context); // regresar
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

              // NOMBRE
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: "Nombre"),
                validator: (v) =>
                    v == null || v.isEmpty ? "Ingresa tu nombre" : null,
              ),

              const SizedBox(height: 15),

              // APELLIDO
              TextFormField(
                controller: _apellidoController,
                decoration: const InputDecoration(labelText: "Apellido"),
                validator: (v) =>
                    v == null || v.isEmpty ? "Ingresa tu apellido" : null,
              ),

              const SizedBox(height: 15),

              // EMAIL
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

              // CONTRASEÑA
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: "Contraseña"),
                obscureText: true,
                validator: (v) {
                  if (v == null || v.isEmpty) return "Ingresa una contraseña";
                  if (v.length < 6) return "Debe tener al menos 6 caracteres";
                  return null;
                },
              ),

              const SizedBox(height: 15),

              // FECHA DE NACIMIENTO CON DATE PICKER
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

                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime(2000),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                    helpText: "Seleccionar fecha",
                    cancelText: "Cancelar",
                    confirmText: "OK",
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
