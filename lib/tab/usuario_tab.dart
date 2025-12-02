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

  List<Map<String, dynamic>> usuarios = [];
  List<Map<String, dynamic>> usuariosFiltrados = [];

  final TextEditingController buscadorCtrl = TextEditingController();

  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarUsuarios();
  }

  Future<void> cargarUsuarios() async {
    try {
      final data = await supabase
          .from('Usuarios')
          .select('id, Email, Nombre, Apellido, Fecha_Nac')
          .order('Nombre', ascending: true);

      setState(() {
        usuarios = List<Map<String, dynamic>>.from(data);
        usuariosFiltrados = usuarios;
        cargando = false;
      });
    } catch (e) {
      setState(() => cargando = false);
    }
  }

  // 🟦 FILTRAR BUSCADOR
  void filtrarUsuarios(String query) {
    final texto = query.toLowerCase();

    setState(() {
      usuariosFiltrados = usuarios.where((u) {
        final nombre = (u['Nombre'] ?? '').toString().toLowerCase();
        final apellido = (u['Apellido'] ?? '').toString().toLowerCase();
        final email = (u['Email'] ?? '').toString().toLowerCase();

        return nombre.contains(texto) ||
            apellido.contains(texto) ||
            email.contains(texto);
      }).toList();
    });
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

    await cargarUsuarios();
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
      await cargarUsuarios();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // 🔍 BUSCADOR
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: buscadorCtrl,
            decoration: InputDecoration(
              hintText: "Buscar usuario...",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: filtrarUsuarios,
          ),
        ),

        // 🔽 LISTA
        Expanded(
          child: usuariosFiltrados.isEmpty
              ? const Center(
                  child: Text(
                    "No se encontraron usuarios",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(14),
                  itemCount: usuariosFiltrados.length,
                  itemBuilder: (context, index) {
                    final user = usuariosFiltrados[index];
                    final nombreCompleto =
                        "${user['Nombre'] ?? ''} ${user['Apellido'] ?? ''}"
                            .trim();

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
                          nombreCompleto.isEmpty
                              ? "Sin nombre"
                              : nombreCompleto,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

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
                ),
        ),
      ],
    );
  }
}
