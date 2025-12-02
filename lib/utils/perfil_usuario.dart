import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PerfilUsuarioPage extends StatefulWidget {
  final int userId;

  const PerfilUsuarioPage({super.key, required this.userId});

  @override
  State<PerfilUsuarioPage> createState() => _PerfilUsuarioPageState();
}

class _PerfilUsuarioPageState extends State<PerfilUsuarioPage> {
  final supabase = Supabase.instance.client;

  Map<String, dynamic>? usuario;
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarPerfil();
  }

  Future<void> cargarPerfil() async {
    try {
      final data = await supabase
          .from("Usuarios")
          .select()
          .eq("id", widget.userId)
          .single();

      setState(() {
        usuario = data;
        cargando = false;
      });
    } catch (e) {
      setState(() => cargando = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al cargar perfil: $e")));
    }
  }

  Future<void> cerrarSesion() async {
    await supabase.auth.signOut();

    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (usuario == null) {
      return const Scaffold(
        body: Center(child: Text("No se encontró el usuario")),
      );
    }

    final String nombre = usuario!["Nombre"] ?? "";
    final String apellido = usuario!["Apellido"] ?? "";
    final String email = usuario!["Email"] ?? "";
    final String fechaNac =
        usuario!["Fecha_Nac"]?.toString() ?? "Sin fecha registrada";

    return Scaffold(
      appBar: AppBar(title: const Text("Perfil del Usuario")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.blue.shade100,
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  "$nombre $apellido",
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 10),
                Text("Email: $email", style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 5),
                Text(
                  "Fecha de nacimiento: $fechaNac",
                  style: const TextStyle(fontSize: 18),
                ),

                const Spacer(),

                // --- BOTÓN DE CERRAR SESIÓN ---
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: cerrarSesion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Cerrar sesión",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
