import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditarCategoriaPage extends StatefulWidget {
  final Map<String, dynamic> categoria;

  const EditarCategoriaPage({super.key, required this.categoria});

  @override
  State<EditarCategoriaPage> createState() => _EditarCategoriaPageState();
}

class _EditarCategoriaPageState extends State<EditarCategoriaPage> {
  final supabase = Supabase.instance.client;

  final _formKey = GlobalKey<FormState>();
  late TextEditingController categoriaController;

  @override
  void initState() {
    super.initState();
    categoriaController = TextEditingController(
      text: widget.categoria['categoria'],
    );
  }

  Future<void> guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await supabase
          .from('categorias')
          .update({'categoria': categoriaController.text})
          .eq('id', widget.categoria['id']);

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al actualizar: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Editar Categoría")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: categoriaController,
                decoration: const InputDecoration(labelText: "Nombre"),
                validator: (v) => v!.isEmpty ? "Campo requerido" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: guardarCambios,
                child: const Text("Guardar Cambios"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
