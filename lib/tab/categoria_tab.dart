import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:estacionamiento/utils/iconos_categoria.dart';
import 'package:estacionamiento/editar/editar_categoria.dart';

class CategoriaTab extends StatefulWidget {
  const CategoriaTab({super.key});

  @override
  State<CategoriaTab> createState() => _CategoriaTabState();
}

class _CategoriaTabState extends State<CategoriaTab> {
  final supabase = Supabase.instance.client;

  List<dynamic> categorias = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarCategorias();
  }

  Future<void> cargarCategorias() async {
    try {
      final data = await supabase
          .from('categorias')
          .select()
          .order('categoria', ascending: true);

      setState(() {
        categorias = data;
        cargando = false;
      });
    } catch (e) {
      setState(() => cargando = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al cargar categorías: $e")));
    }
  }

  Future<void> borrarCategoria(int id) async {
    try {
      await supabase.from('categorias').delete().eq('id', id);
      cargarCategorias();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al borrar: $e")));
    }
  }

  void confirmarBorrado(int id, String nombre) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirmar borrado"),
        content: Text("¿Eliminar la categoría \"$nombre\"?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              borrarCategoria(id);
            },
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (categorias.isEmpty) {
      return const Center(
        child: Text(
          "No hay categorías registradas",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: categorias.length,
      itemBuilder: (context, index) {
        final cat = categorias[index];
        final id = cat['id'];
        final nombre = cat['categoria'];

        return Card(
          elevation: 3,
          child: ListTile(
            leading: Icon(
              getCategoriaIcon(nombre),
              size: 40,
              color: Colors.blueGrey,
            ),
            title: Text(
              nombre,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            trailing: PopupMenuButton(
              onSelected: (value) async {
                if (value == 'ver') {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("Categoría"),
                      content: Row(
                        children: [
                          Icon(
                            getCategoriaIcon(nombre),
                            size: 45,
                            color: Colors.blueGrey,
                          ),
                          const SizedBox(width: 15),
                          Text(nombre, style: const TextStyle(fontSize: 18)),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cerrar"),
                        ),
                      ],
                    ),
                  );
                } else if (value == 'editar') {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditarCategoriaPage(categoria: cat),
                    ),
                  );

                  if (result != null) cargarCategorias();
                } else if (value == 'borrar') {
                  confirmarBorrado(id, nombre);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'ver',
                  child: Row(
                    children: [
                      Icon(Icons.visibility, color: Colors.blue),
                      SizedBox(width: 10),
                      Text("Ver"),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'editar',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.orange),
                      SizedBox(width: 10),
                      Text("Editar"),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'borrar',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 10),
                      Text("Borrar"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
