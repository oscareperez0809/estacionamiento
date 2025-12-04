import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegistrarCategoriaPage extends StatefulWidget {
  const RegistrarCategoriaPage({super.key});

  @override
  State<RegistrarCategoriaPage> createState() => _RegistrarCategoriaPageState();
}

class _RegistrarCategoriaPageState extends State<RegistrarCategoriaPage> {
  final TextEditingController _nombreCtrl = TextEditingController();
  final supabase = Supabase.instance.client;

  // Función para capitalizar la primera letra
  String corregirOrtografia(String texto) {
    if (texto.isEmpty) return '';
    return texto[0].toUpperCase() + texto.substring(1).toLowerCase();
  }

  Future<void> registrarCategoria() async {
    String nombre = _nombreCtrl.text.trim();
    nombre = corregirOrtografia(nombre); // aplicar corrección ortográfica

    if (nombre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("El nombre no puede estar vacío")),
      );
      return;
    }

    try {
      // 🔍 Verificar si ya existe la categoría (case insensitive)
      final existe = await supabase
          .from('categorias')
          .select('*')
          .ilike('categoria', nombre);

      if (existe.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "La categoría '$nombre' ya está registrada. Ingresa otra distinta.",
            ),
          ),
        );
        return; // salir sin registrar
      }

      // Registrar categoría
      await supabase.from('categorias').insert({'categoria': nombre});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Categoría registrada correctamente ✔")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registrar Categoría")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _nombreCtrl,
              decoration: const InputDecoration(
                labelText: "Nombre de la categoría",
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: registrarCategoria,
              child: const Text("Registrar"),
            ),
          ],
        ),
      ),
    );
  }
}
