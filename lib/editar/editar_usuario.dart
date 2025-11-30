import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bcrypt/bcrypt.dart';

class EditarUsuarioPage extends StatefulWidget {
  final Map<String, dynamic> usuario;

  const EditarUsuarioPage({super.key, required this.usuario});

  @override
  State<EditarUsuarioPage> createState() => _EditarUsuarioPageState();
}

class _EditarUsuarioPageState extends State<EditarUsuarioPage> {
  final supabase = Supabase.instance.client;

  late TextEditingController nombreController;
  late TextEditingController apellidoController;
  late TextEditingController emailController;
  late TextEditingController contraseniaController;

  DateTime? fechaNacimiento;

  bool ocultarContrasena = true; // 👁 para mostrar/ocultar

  @override
  void initState() {
    super.initState();

    nombreController = TextEditingController(
      text: widget.usuario['Nombre'] ?? "",
    );
    apellidoController = TextEditingController(
      text: widget.usuario['Apellido'] ?? "",
    );
    emailController = TextEditingController(
      text: widget.usuario['Email'] ?? "",
    );

    // ⚠️ Ya NO mostrar la contraseña real (por seguridad)
    contraseniaController = TextEditingController(text: "");

    if (widget.usuario['Fecha_Nac'] != null) {
      fechaNacimiento = DateTime.tryParse(widget.usuario['Fecha_Nac']);
    }
  }

  Future<void> actualizarUsuario() async {
    try {
      String? hashedPassword;

      if (contraseniaController.text.trim().isNotEmpty) {
        // 🔥 Hash bcrypt OFICIAL
        hashedPassword = BCrypt.hashpw(
          contraseniaController.text.trim(),
          BCrypt.gensalt(),
        );
      }

      await supabase
          .from('Usuarios')
          .update({
            'Nombre': nombreController.text.trim(),
            'Apellido': apellidoController.text.trim(),
            'Email': emailController.text.trim(),

            // 🔥 Solo actualizar contraseña si el usuario escribió algo
            if (hashedPassword != null) 'Contrasenia': hashedPassword,

            'Fecha_Nac': fechaNacimiento != null
                ? DateFormat('yyyy-MM-dd').format(fechaNacimiento!)
                : null,
          })
          .eq("id", widget.usuario['id']);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Usuario actualizado correctamente")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al actualizar: $e")));
    }
  }

  Future<void> seleccionarFecha() async {
    DateTime fechaInicial = fechaNacimiento ?? DateTime(2000);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fechaInicial,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        fechaNacimiento = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar Usuario"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            TextFormField(
              controller: nombreController,
              decoration: const InputDecoration(
                labelText: "Nombre",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            TextFormField(
              controller: apellidoController,
              decoration: const InputDecoration(
                labelText: "Apellido",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 15),

            // 🔥 Campo contraseña con icono de ojo
            TextFormField(
              controller: contraseniaController,
              obscureText: ocultarContrasena,
              decoration: InputDecoration(
                labelText: "Contraseña (solo si quieres cambiarla)",
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    ocultarContrasena ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      ocultarContrasena = !ocultarContrasena;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: Text(
                    fechaNacimiento != null
                        ? "Fecha de Nac.: ${DateFormat('dd/MM/yyyy').format(fechaNacimiento!)}"
                        : "Sin fecha seleccionada",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_month, color: Colors.blue),
                  onPressed: seleccionarFecha,
                ),
              ],
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: actualizarUsuario,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blueAccent,
              ),
              child: const Text(
                "Guardar Cambios",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
