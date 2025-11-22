import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:estacionamiento/utils/iconos_marca.dart';

class MarcaTab extends StatefulWidget {
  const MarcaTab({super.key});

  @override
  State<MarcaTab> createState() => _MarcaTabState();
}

class _MarcaTabState extends State<MarcaTab> {
  final supabase = Supabase.instance.client;

  List<dynamic> marcas = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarMarcas();
  }

  Future<void> cargarMarcas() async {
    try {
      final data = await supabase.from('marcas').select();

      setState(() {
        marcas = data;
        cargando = false;
      });
    } catch (e) {
      setState(() => cargando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al cargar las marcas: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (marcas.isEmpty) {
      return const Center(
        child: Text(
          "No hay marcas registradas",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: marcas.length,
      itemBuilder: (context, index) {
        final marca = marcas[index];
        final nombre = marca['marcas'];

        return Card(
          elevation: 3,
          child: ListTile(
            leading: Image.asset(
              getMarcaIcon(nombre),     // ← Logo PNG
              width: 40,
              height: 40,
              fit: BoxFit.contain,
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
