import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditarPensionadoPage extends StatefulWidget {
  final Map<String, dynamic> pensionado;

  const EditarPensionadoPage({super.key, required this.pensionado});

  @override
  State<EditarPensionadoPage> createState() => _EditarPensionadoPageState();
}

class _EditarPensionadoPageState extends State<EditarPensionadoPage> {
  final supabase = Supabase.instance.client;

  // Controladores de texto
  late TextEditingController apellidoCtrl;
  late TextEditingController nombreCtrl;
  late TextEditingController telefonoCtrl;
  late TextEditingController placasCtrl;
  late TextEditingController pagoCtrl;

  // Dropdowns
  String? marcaSeleccionada;
  String? categoriaSeleccionada;

  // Listas desde Supabase
  List<String> marcas = [];
  List<String> categorias = [];

  // Fechas
  DateTime? fechaInicio;
  DateTime? fechaFin;
  final formatoFecha = DateFormat("yyyy-MM-dd");

  @override
  void initState() {
    super.initState();

    // Inicializar campos existentes
    apellidoCtrl = TextEditingController(text: widget.pensionado["Apellido"]);
    nombreCtrl = TextEditingController(text: widget.pensionado["Nombre"]);
    telefonoCtrl = TextEditingController(
      text: widget.pensionado["Teléfono"]?.toString(),
    );
    placasCtrl = TextEditingController(text: widget.pensionado["Placas"]);
    pagoCtrl = TextEditingController(
      text: widget.pensionado["Pago_Men"]?.toString(),
    );

    marcaSeleccionada = widget.pensionado["Marca"];
    categoriaSeleccionada = widget.pensionado["Categoria"];

    fechaInicio = widget.pensionado["Fecha_Inicio"] != null
        ? DateTime.parse(widget.pensionado["Fecha_Inicio"])
        : null;

    fechaFin = widget.pensionado["Fecha_Fin"] != null
        ? DateTime.parse(widget.pensionado["Fecha_Fin"])
        : null;

    cargarDatos();
  }

  Future<void> cargarDatos() async {
    final marcasData = await supabase.from("marcas").select("marcas");
    final categoriasData = await supabase
        .from("categorias")
        .select("categoria");

    setState(() {
      marcas = marcasData.map<String>((e) => e["marcas"].toString()).toList();
      categorias = categoriasData
          .map<String>((e) => e["categoria"].toString())
          .toList();
    });
  }

  Future<void> seleccionarFechaInicio() async {
    final nuevaFecha = await showDatePicker(
      context: context,
      initialDate: fechaInicio ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (nuevaFecha != null) {
      setState(() => fechaInicio = nuevaFecha);
    }
  }

  Future<void> seleccionarFechaFin() async {
    final nuevaFecha = await showDatePicker(
      context: context,
      initialDate: fechaFin ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (nuevaFecha != null) {
      setState(() => fechaFin = nuevaFecha);
    }
  }

  Future<void> guardar() async {
    final id = widget.pensionado["id"];

    await supabase
        .from("Pensionados")
        .update({
          "Apellido": apellidoCtrl.text,
          "Nombre": nombreCtrl.text,
          "Teléfono": int.tryParse(telefonoCtrl.text),
          "Marca": marcaSeleccionada,
          "Categoria": categoriaSeleccionada,
          "Placas": placasCtrl.text,
          "Pago_Men": double.tryParse(pagoCtrl.text),
          "Fecha_Inicio": fechaInicio != null
              ? formatoFecha.format(fechaInicio!)
              : null,
          "Fecha_Fin": fechaFin != null ? formatoFecha.format(fechaFin!) : null,
        })
        .eq("id", id);

    if (mounted) Navigator.pop(context);
  }

  // ------------------ WIDGET REUTILIZABLES ----------------------------------

  Widget campoTexto(
    String label,
    TextEditingController controller, {
    TextInputType tipo = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: tipo,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget dropdownCampo(
    String label,
    String? valor,
    List<String> items,
    void Function(String?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: valor,
        items: items
            .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget fechaCampo(String label, DateTime? fecha, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AbsorbPointer(
          child: TextField(
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(),
            ),
            controller: TextEditingController(
              text: fecha != null ? formatoFecha.format(fecha) : "",
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------ UI PRINCIPAL -------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Editar Pensionado")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            campoTexto("Apellido", apellidoCtrl),
            campoTexto("Nombre", nombreCtrl),
            campoTexto("Teléfono", telefonoCtrl, tipo: TextInputType.number),
            campoTexto("Placas", placasCtrl),
            campoTexto("Pago Mensual", pagoCtrl, tipo: TextInputType.number),

            dropdownCampo("Marca", marcaSeleccionada, marcas, (v) {
              setState(() => marcaSeleccionada = v);
            }),

            dropdownCampo("Categoría", categoriaSeleccionada, categorias, (v) {
              setState(() => categoriaSeleccionada = v);
            }),

            fechaCampo("Fecha Inicio", fechaInicio, seleccionarFechaInicio),
            fechaCampo("Fecha Fin", fechaFin, seleccionarFechaFin),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: guardar,
              child: const Text("Guardar Cambios"),
            ),
          ],
        ),
      ),
    );
  }
}
