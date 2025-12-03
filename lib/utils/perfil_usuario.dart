import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'session.dart';

class PerfilUsuarioPage extends StatefulWidget {
  final int userId;

  const PerfilUsuarioPage({super.key, required this.userId});

  @override
  State<PerfilUsuarioPage> createState() => _PerfilUsuarioPageState();
}

class _PerfilUsuarioPageState extends State<PerfilUsuarioPage> {
  final supabase = Supabase.instance.client;
  Map<String, dynamic>? userData;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    cargarUsuario();
  }

  Future<void> cargarUsuario() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final response = await supabase
          .from('Usuarios')
          .select()
          .eq('id', widget.userId)
          .single();

      setState(() {
        userData = Map<String, dynamic>.from(response);
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = "Error cargando datos: $e";
        loading = false;
      });
    }
  }

  Future<void> _cerrarSesion() async {
    try {
      // 1) Cerrar sesión en Supabase (si estás usando auth allí)
      await supabase.auth.signOut();

      // 2) Limpiar sesión local (tu SessionManager)
      SessionManager.logout();

      // 3) Espera una microtarea antes de la navegación para evitar rebuilds intermedios
      Future.microtask(() {
        if (!mounted) return;
        // Asume que la ruta del login en main.dart es '/'
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      });
    } catch (e) {
      // Mostrar error si algo falla
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cerrar sesión: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f6fa),
      appBar: AppBar(
        title: const Text("Perfil del Usuario"),
        elevation: 0,
        centerTitle: true,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : (error != null)
              ? Center(child: Text(error!))
              : (userData == null)
                  ? const Center(child: Text("Usuario no encontrado"))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // FOTO DE PERFIL
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.blueAccent.shade100,
                            child: const Icon(
                              Icons.person,
                              size: 70,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 20),

                          // NOMBRE
                          Text(
                            userData!['Nombre'] ?? '',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 5),

                          // EMAIL
                          Text(
                            userData!['Email'] ?? '',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),

                          const SizedBox(height: 30),

                          // CARD DE INFO
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.badge, color: Colors.blue),
                                    const SizedBox(width: 10),
                                    Text(
                                      "Información del usuario",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                infoItem("Nombre", userData!['Nombre'] ?? ''),
                                const Divider(),
                                infoItem("Correo", userData!['Email'] ?? ''),
                                const Divider(),
                                infoItem("Fecha nacimiento",
                                    userData!['Fecha_Nac']?.toString() ?? '---'),
                              ],
                            ),
                          ),

                          const SizedBox(height: 40),

                          // BOTÓN CERRAR SESIÓN
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.logout),
                              label: const Text(
                                "Cerrar Sesión",
                                style: TextStyle(fontSize: 18),
                              ),
                              onPressed: _cerrarSesion,
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }

  Widget infoItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 16, color: Colors.grey.shade700)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
