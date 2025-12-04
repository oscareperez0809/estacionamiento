import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegistrarCarroPage extends StatefulWidget {
  const RegistrarCarroPage({super.key});

  @override
  State<RegistrarCarroPage> createState() => _RegistrarCarroPageState();
}

class _RegistrarCarroPageState extends State<RegistrarCarroPage> {
  final _formKey = GlobalKey<FormState>();

  final placasCtrl = TextEditingController();
  final fechaEntradaCtrl = TextEditingController();
  final horaEntradaCtrl = TextEditingController();

  DateTime? fechaEntrada;
  TimeOfDay? horaEntrada;

  List<dynamic> listaCategorias = [];
  List<dynamic> listaVehiculos = [];

  int? categoriaSeleccionada;
  int? vehiculoSeleccionado;

  @override
  void initState() {
    super.initState();
    cargarCategorias();
    cargarVehiculos();
  }

  Future<void> cargarCategorias() async {
    final res = await Supabase.instance.client.from("categorias").select("*");
    setState(() {
      listaCategorias = res;
    });
  }

  Future<void> cargarVehiculos() async {
    final res = await Supabase.instance.client
        .from("marcas")
        .select("*"); // la tabla sigue siendo "marcas"
    setState(() {
      listaVehiculos = res;
    });
  }

  Future<void> seleccionarFechaEntrada() async {
    final DateTime? seleccion = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: "Seleccionar fecha de entrada",
    );

    if (seleccion != null) {
      setState(() {
        fechaEntrada = seleccion;
        fechaEntradaCtrl.text = DateFormat("yyyy-MM-dd").format(fechaEntrada!);
      });
    }
  }

  Future<void> seleccionarHoraEntrada() async {
    final TimeOfDay? seleccion = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (seleccion != null) {
      setState(() {
        horaEntrada = seleccion;
        horaEntradaCtrl.text = seleccion.format(context);
      });
    }
  }

  Future<void> guardarCarro() async {
    try {
      final placaIngresada = placasCtrl.text.trim().toUpperCase();

      // 🔍 Verificar si ya existe la placa
      final existe = await Supabase.instance.client
          .from("Carros_Estacionados")
          .select("*")
          .ilike("placas", placaIngresada);

      if (existe.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "La placa '$placaIngresada' ya está registrada. Ingresa otra distinta.",
            ),
          ),
        );
        return; // salir sin guardar
      }

      final categoriaTexto = listaCategorias.firstWhere(
        (c) => c['id'] == categoriaSeleccionada,
      )['categoria'];

      final vehiculoTexto = listaVehiculos.firstWhere(
        (v) => v['id'] == vehiculoSeleccionado,
      )['marcas'];

      await Supabase.instance.client.from("Carros_Estacionados").insert({
        "placas": placaIngresada,
        "categoria": categoriaTexto,
        "vehiculo": vehiculoTexto,
        "fecha_entrada": fechaEntradaCtrl.text,
        "hora_entrada": horaEntradaCtrl.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Carro registrado correctamente")),
      );

      // Limpiar campos después de registrar
      placasCtrl.clear();
      fechaEntradaCtrl.clear();
      horaEntradaCtrl.clear();
      setState(() {
        categoriaSeleccionada = null;
        vehiculoSeleccionado = null;
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
        title: const Text("Registrar Carro"),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _input("Placas", placasCtrl),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _dropdownCategoria()),
                  const SizedBox(width: 14),
                  Expanded(child: _dropdownVehiculo()),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: seleccionarFechaEntrada,
                      child: AbsorbPointer(
                        child: _input("Fecha Entrada", fechaEntradaCtrl),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: seleccionarHoraEntrada,
                      child: AbsorbPointer(
                        child: _input("Hora Entrada", horaEntradaCtrl),
                      ),
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
                      await guardarCarro();
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

  // -------------------------
  // Widgets Reutilizables
  // -------------------------
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

  Widget _dropdownVehiculo() {
    return DropdownButtonFormField<int>(
      decoration: InputDecoration(
        labelText: "Vehículo",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      value: vehiculoSeleccionado,
      items: listaVehiculos.map((v) {
        return DropdownMenuItem<int>(
          value: v['id'] as int,
          child: Text(v['marcas']),
        );
      }).toList(),
      onChanged: (value) => setState(() => vehiculoSeleccionado = value),
      validator: (v) => v == null ? "Selecciona un vehículo" : null,
    );
  }
}
