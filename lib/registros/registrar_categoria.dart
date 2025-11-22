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

  Future<void> registrarCategoria() async {
    final nombre = _nombreCtrl.text.trim(); // ← variable correcta

    if (nombre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("El nombre no puede estar vacío")),
      );
      return;
    }

    try {
      await supabase.from('categorias').insert({
        'categoria': nombre, // ← aquí usas 'nombre', no 'categoria'
      });

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
