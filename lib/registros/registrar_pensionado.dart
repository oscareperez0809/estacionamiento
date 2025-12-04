import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegistrarPensionadoPage extends StatefulWidget {
  const RegistrarPensionadoPage({super.key});

  @override
  State<RegistrarPensionadoPage> createState() =>
      _RegistrarPensionadoPageState();
}

class _RegistrarPensionadoPageState extends State<RegistrarPensionadoPage> {
  final _formKey = GlobalKey<FormState>();

  final nombreCtrl = TextEditingController();
  final apellidoCtrl = TextEditingController();
  final telefonoCtrl = TextEditingController();
  final placasCtrl = TextEditingController();
  final pagoCtrl = TextEditingController();

  final fechaInicioCtrl = TextEditingController();
  final fechaFinalCtrl = TextEditingController();

  DateTime? fechaInicio;
  DateTime? fechaFinal;

  List<dynamic> listaCategorias = [];
  List<dynamic> listaMarcas = [];

  int? categoriaSeleccionada;
  int? marcaSeleccionada;

  @override
  void initState() {
    super.initState();
    cargarCategorias();
    cargarMarcas();
  }

  Future<void> cargarCategorias() async {
    final res = await Supabase.instance.client.from("categorias").select("*");
    setState(() {
      listaCategorias = res;
    });
  }

  Future<void> cargarMarcas() async {
    final res = await Supabase.instance.client.from("marcas").select("*");
    setState(() {
      listaMarcas = res;
    });
  }

  // ------------------- SELECCIONAR FECHA DE INICIO -------------------
  Future<void> seleccionarFecha() async {
    final DateTime? seleccion = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: "Seleccionar fecha de inicio",
    );

    if (seleccion != null) {
      setState(() {
        fechaInicio = seleccion;
        fechaFinal = seleccion.add(const Duration(days: 30));

        fechaInicioCtrl.text = DateFormat("yyyy-MM-dd").format(fechaInicio!);
        fechaFinalCtrl.text = DateFormat("yyyy-MM-dd").format(fechaFinal!);
      });
    }
  }

  // ------------------- GUARDAR PENSIONADO -------------------
  Future<void> guardarPensionado() async {
    try {
      // Validar teléfono único
      final telExistente = await Supabase.instance.client
          .from("Pensionados")
          .select('*')
          .eq('Teléfono', telefonoCtrl.text.trim());

      if (telExistente.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("El número de teléfono ya está registrado"),
          ),
        );
        return;
      }

      // Validar placas únicas
      final placasExistentes = await Supabase.instance.client
          .from("Pensionados")
          .select('*')
          .eq('Placas', placasCtrl.text.trim());

      if (placasExistentes.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Las placas ya están registradas. Ingresa otras."),
          ),
        );
        return;
      }

      // Obtener texto según IDs
      final categoriaTexto = listaCategorias.firstWhere(
        (c) => c['id'] == categoriaSeleccionada,
      )['categoria'];
      final marcaTexto = listaMarcas.firstWhere(
        (m) => m['id'] == marcaSeleccionada,
      )['marcas'];

      await Supabase.instance.client.from("Pensionados").insert({
        "Nombre": nombreCtrl.text.trim(),
        "Apellido": apellidoCtrl.text.trim(),
        "Teléfono": telefonoCtrl.text.trim(),
        "Marca": marcaTexto,
        "Categoria": categoriaTexto,
        "Placas": placasCtrl.text.trim(),
        "Pago_Men": double.tryParse(pagoCtrl.text) ?? 0,
        "Fecha_Inicio": fechaInicioCtrl.text,
        "Fecha_Fin": fechaFinalCtrl.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pensionado registrado correctamente")),
      );

      // Limpiar campos
      _formKey.currentState!.reset();
      nombreCtrl.clear();
      apellidoCtrl.clear();
      telefonoCtrl.clear();
      placasCtrl.clear();
      pagoCtrl.clear();
      fechaInicioCtrl.clear();
      fechaFinalCtrl.clear();
      setState(() {
        categoriaSeleccionada = null;
        marcaSeleccionada = null;
        fechaInicio = null;
        fechaFinal = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registrar Pensionado"),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "DATOS DEL PENSIONADO",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(child: _input("Nombre", nombreCtrl)),
                  const SizedBox(width: 12),
                  Expanded(child: _input("Apellido", apellidoCtrl)),
                ],
              ),
              const SizedBox(height: 20),
              _input("No. de Teléfono", telefonoCtrl),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(child: _dropdownCategoria()),
                  const SizedBox(width: 12),
                  Expanded(child: _dropdownMarca()),
                ],
              ),

              const SizedBox(height: 20),
              _input("Placas", placasCtrl),

              const SizedBox(height: 40),
              const Text(
                "DATOS DE MENSUALIDAD",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _input("Pago de mensualidad", pagoCtrl),

              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: seleccionarFecha,
                      child: AbsorbPointer(
                        child: _input("Fecha inicio", fechaInicioCtrl),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AbsorbPointer(
                      child: _input("Fecha final (automática)", fechaFinalCtrl),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    backgroundColor: Colors.blueAccent,
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await guardarPensionado();
                    }
                  },
                  child: const Text(
                    "Registrar",
                    style: TextStyle(fontSize: 19),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------- Widgets Reutilizables -------------------------
  Widget _input(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (value) =>
          value == null || value.isEmpty ? "Campo obligatorio" : null,
    );
  }

  Widget _dropdownCategoria() {
    return DropdownButtonFormField<int>(
      decoration: InputDecoration(
        labelText: "Categoría",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      value: categoriaSeleccionada,
      items: listaCategorias.map((cat) {
        return DropdownMenuItem<int>(
          value: cat['id'] as int,
          child: Text(cat['categoria']),
        );
      }).toList(),
      onChanged: (value) => setState(() => categoriaSeleccionada = value),
      validator: (v) => v == null ? "Selecciona una categoría" : null,
    );
  }

  Widget _dropdownMarca() {
    return DropdownButtonFormField<int>(
      decoration: InputDecoration(
        labelText: "Marca",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      value: marcaSeleccionada,
      items: listaMarcas.map((m) {
        return DropdownMenuItem<int>(
          value: m['id'] as int,
          child: Text(m['marcas']),
        );
      }).toList(),
      onChanged: (value) => setState(() => marcaSeleccionada = value),
      validator: (v) => v == null ? "Selecciona una marca" : null,
    );
  }
}
