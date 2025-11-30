import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:estacionamiento/editar/editar_usuario.dart';

class UsuarioTab extends StatefulWidget {
  const UsuarioTab({super.key});

  @override
  State<UsuarioTab> createState() => _UsuarioTabState();
}

class _UsuarioTabState extends State<UsuarioTab> {
  final supabase = Supabase.instance.client;

  late Future<List<Map<String, dynamic>>> futureUsuarios;

  @override
  void initState() {
    super.initState();
    futureUsuarios = cargarUsuarios();
  }

  Future<List<Map<String, dynamic>>> cargarUsuarios() async {
    return await supabase
        .from('Usuarios')
        .select('id, Email, Nombre, Apellido, Fecha_Nac');
  }

  // 🔵 VER
  void verUsuario(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Detalles del usuario"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Nombre: ${user['Nombre']} ${user['Apellido']}"),
            Text("Email: ${user['Email']}"),
            Text("Fecha de nacimiento: ${user['Fecha_Nac'] ?? '--'}"),
          ],
        ),
        actions: [
          TextButton(
            child: const Text("Cerrar"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  // 🟢 EDITAR
  void editarUsuario(Map<String, dynamic> user) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditarUsuarioPage(usuario: user)),
    );

    setState(() {
      futureUsuarios = cargarUsuarios();
    });
  }

  // 🔴 ELIMINAR
  void eliminarUsuario(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirmar eliminación"),
        content: const Text("¿Seguro que quieres eliminar este usuario?"),
        actions: [
          TextButton(
            child: const Text("Cancelar"),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Eliminar"),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await supabase.from('Usuarios').delete().eq('id', id);
      setState(() {
        futureUsuarios = cargarUsuarios();
      });
    }
  }

  // 🔵 UI
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: futureUsuarios,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final usuarios = snapshot.data!;

        if (usuarios.isEmpty) {
          return const Center(
            child: Text(
              'No hay usuarios registrados',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(14),
          itemCount: usuarios.length,
          itemBuilder: (context, index) {
            final user = usuarios[index];

            final nombreCompleto = "${user['Nombre'] ?? ''}".trim();

            return Card(
              elevation: 3,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),

                leading: const Icon(
                  Icons.person,
                  size: 35,
                  color: Colors.blueAccent,
                ),

                title: Text(
                  nombreCompleto.isEmpty ? "Sin nombre" : nombreCompleto,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [const SizedBox(height: 4)],
                ),

                // 🔥 ICONOS A LA MISMA ALTURA
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.remove_red_eye,
                        color: Colors.blue,
                      ),
                      onPressed: () => verUsuario(user),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.green),
                      onPressed: () => editarUsuario(user),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => eliminarUsuario(user['id']),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
