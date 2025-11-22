import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:estacionamiento/utils/iconos_categoria.dart';

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
      final data = await supabase.from('categorias').select();

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
          ),
        );
      },
    );
  }
}
