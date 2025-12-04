import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:estacionamiento/tab/pensionados_tab.dart'; // Importar Pensionado

class EditarPensionadoPage extends StatefulWidget {
  final Pensionado pensionado;

  const EditarPensionadoPage({super.key, required this.pensionado});

  @override
  State<EditarPensionadoPage> createState() => _EditarPensionadoPageState();
}

class _EditarPensionadoPageState extends State<EditarPensionadoPage> {
  final supabase = Supabase.instance.client;

  late TextEditingController apellidoCtrl;
  late TextEditingController nombreCtrl;
  late TextEditingController telefonoCtrl;
  late TextEditingController placasCtrl;
  late TextEditingController pagoCtrl;

  late TextEditingController fechaInicioCtrl;
  late TextEditingController fechaFinCtrl;

  String? marcaSeleccionada;
  String? categoriaSeleccionada;

  List<String> marcas = [];
  List<String> categorias = [];

  DateTime? fechaInicio;
  DateTime? fechaFin;
  final formatoFecha = DateFormat("yyyy-MM-dd");

  @override
  void initState() {
    super.initState();

    apellidoCtrl = TextEditingController(text: widget.pensionado.apellido);
    nombreCtrl = TextEditingController(text: widget.pensionado.nombre);
    telefonoCtrl = TextEditingController(text: widget.pensionado.telefono);
    placasCtrl = TextEditingController(text: widget.pensionado.placas);
    pagoCtrl = TextEditingController(
      text: widget.pensionado.pagoMensual.toString(),
    );

    marcaSeleccionada = widget.pensionado.marca;
    categoriaSeleccionada = widget.pensionado.categoria;

    fechaInicio = widget.pensionado.fechaInicio;
    fechaFin = widget.pensionado.fechaFin.value;

    fechaInicioCtrl = TextEditingController(
      text: fechaInicio != null ? formatoFecha.format(fechaInicio!) : '',
    );
    fechaFinCtrl = TextEditingController(
      text: fechaFin != null ? formatoFecha.format(fechaFin!) : '',
    );

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
      setState(() {
        fechaInicio = nuevaFecha;
        fechaInicioCtrl.text = formatoFecha.format(fechaInicio!);

        // Ajustar fechaFin automáticamente si es menor
        if (fechaFin == null || fechaFin!.isBefore(fechaInicio!)) {
          fechaFin = fechaInicio!.add(const Duration(days: 30));
          fechaFinCtrl.text = formatoFecha.format(fechaFin!);
        }
      });
    }
  }

  Future<void> seleccionarFechaFin() async {
    final nuevaFecha = await showDatePicker(
      context: context,
      initialDate: fechaFin ?? (fechaInicio ?? DateTime.now()),
      firstDate: fechaInicio ?? DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (nuevaFecha != null) {
      setState(() {
        fechaFin = nuevaFecha;
        fechaFinCtrl.text = formatoFecha.format(fechaFin!);
      });
    }
  }

  Future<void> guardar() async {
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
        .eq("id", widget.pensionado.id);

    if (mounted) Navigator.pop(context, true); // true para refrescar la lista
  }

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
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget fechaCampo(
    String label,
    TextEditingController controller,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AbsorbPointer(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ),
    );
  }

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
            dropdownCampo(
              "Marca",
              marcaSeleccionada,
              marcas,
              (v) => setState(() => marcaSeleccionada = v),
            ),
            dropdownCampo(
              "Categoría",
              categoriaSeleccionada,
              categorias,
              (v) => setState(() => categoriaSeleccionada = v),
            ),
            fechaCampo("Fecha Inicio", fechaInicioCtrl, seleccionarFechaInicio),
            fechaCampo("Fecha Fin", fechaFinCtrl, seleccionarFechaFin),
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
