import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditarCarroPage extends StatefulWidget {
  final Map<String, dynamic> carro;

  const EditarCarroPage({super.key, required this.carro});

  @override
  State<EditarCarroPage> createState() => _EditarCarroPageState();
}

class _EditarCarroPageState extends State<EditarCarroPage> {
  final _formKey = GlobalKey<FormState>();

  final placasCtrl = TextEditingController();
  final fechaEntradaCtrl = TextEditingController();
  final horaEntradaCtrl = TextEditingController();
  final fechaSalidaCtrl = TextEditingController();
  final horaSalidaCtrl = TextEditingController();
  final tiempoCtrl = TextEditingController();
  final tarifaCtrl = TextEditingController();

  String? vehiculoSeleccionado;
  String? categoriaSeleccionada;

  List<String> listaVehiculos = [];
  List<String> listaCategorias = [];

  @override
  void initState() {
    super.initState();

    placasCtrl.text = widget.carro['placas'] ?? "";
    fechaEntradaCtrl.text = widget.carro['fecha_entrada'] ?? "";
    horaEntradaCtrl.text = widget.carro['hora_entrada'] ?? "";
    fechaSalidaCtrl.text = widget.carro['fecha_salida'] ?? "";
    horaSalidaCtrl.text = widget.carro['hora_salida'] ?? "";
    tiempoCtrl.text = widget.carro['tiempo'] ?? "";
    tarifaCtrl.text = widget.carro['importe']?.toString() ?? "";

    vehiculoSeleccionado = widget.carro['vehiculo'];
    categoriaSeleccionada = widget.carro['categoria'];

    cargarOpciones(); // carga listas desde Supabase
    calcularTodo();
  }

  Future<void> cargarOpciones() async {
    try {
      final vehiculos = await Supabase.instance.client
          .from('marcas')
          .select('marcas')
          .order('marcas')
          .then((res) => (res as List).map((e) => e['marcas'] as String).toList());

      final categorias = await Supabase.instance.client
          .from('categorias')
          .select('categoria')
          .order('categoria')
          .then((res) => (res as List).map((e) => e['categoria'] as String).toList());

      setState(() {
        listaVehiculos = vehiculos;
        listaCategorias = categorias;
      });
    } catch (_) {}
  }

  int calcularTarifa(DateTime entrada, DateTime salida) {
    final minutos = salida.difference(entrada).inMinutes;
    if (minutos <= 60) return 25;

    int restante = minutos - 60;
    int fracciones = (restante / 30).ceil();
    int total = 25;

    for (int i = 1; i <= fracciones; i++) {
      total += (i % 2 == 1) ? 13 : 12;
    }
    return total;
  }

  TimeOfDay _parseTime(String h) {
    try {
      final dt = DateFormat("HH:mm:ss").parse(h);
      return TimeOfDay(hour: dt.hour, minute: dt.minute);
    } catch (_) {
      return const TimeOfDay(hour: 0, minute: 0);
    }
  }

  void calcularTodo() {
    if (fechaEntradaCtrl.text.isEmpty ||
        horaEntradaCtrl.text.isEmpty ||
        fechaSalidaCtrl.text.isEmpty ||
        horaSalidaCtrl.text.isEmpty) {
      setState(() {
        tiempoCtrl.text = "";
        tarifaCtrl.text = "";
      });
      return;
    }

    try {
      final entradaFecha = DateTime.parse(fechaEntradaCtrl.text);
      final entradaHora = _parseTime(horaEntradaCtrl.text);
      final entrada = DateTime(
        entradaFecha.year,
        entradaFecha.month,
        entradaFecha.day,
        entradaHora.hour,
        entradaHora.minute,
      );

      final salida = DateTime.parse("${fechaSalidaCtrl.text} ${horaSalidaCtrl.text}");

      final diff = salida.difference(entrada);
      if (diff.inMinutes < 0) return;

      final h = diff.inHours;
      final m = diff.inMinutes % 60;
      String tiempoInterval =
          "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:00";

      setState(() {
        tiempoCtrl.text = tiempoInterval;
        tarifaCtrl.text = calcularTarifa(entrada, salida).toString();
      });
    } catch (_) {}
  }

  Future<void> pickFecha(TextEditingController ctrl) async {
    DateTime actual;
    try {
      actual = DateTime.parse(ctrl.text);
    } catch (_) {
      actual = DateTime.now();
    }

    final fecha = await showDatePicker(
      context: context,
      initialDate: actual,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (fecha != null) {
      ctrl.text = DateFormat("yyyy-MM-dd").format(fecha);
      calcularTodo();
    }
  }

  Future<void> pickHora(TextEditingController ctrl) async {
    TimeOfDay actual;
    try {
      actual = _parseTime(ctrl.text);
    } catch (_) {
      actual = TimeOfDay.now();
    }

    final hora = await showTimePicker(context: context, initialTime: actual);

    if (hora != null) {
      ctrl.text =
          "${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}:00";
      calcularTodo();
    }
  }

  Future<void> guardarSalida() async {
    if (!_formKey.currentState!.validate()) return;
    if (vehiculoSeleccionado == null || categoriaSeleccionada == null) return;

    final carroId = widget.carro['id'];
    if (carroId == null) return;

    try {
      final importe = double.tryParse(tarifaCtrl.text) ?? 0;

      await Supabase.instance.client
          .from('Carros_Estacionados')
          .update({
            "fecha_entrada": fechaEntradaCtrl.text,
            "hora_entrada": horaEntradaCtrl.text,
            "placas": placasCtrl.text,
            "vehiculo": vehiculoSeleccionado,
            "categoria": categoriaSeleccionada,
            "fecha_salida": fechaSalidaCtrl.text,
            "hora_salida": horaSalidaCtrl.text,
            "tiempo": tiempoCtrl.text,
            "importe": importe,
          })
          .eq("id", carroId)
          .select();

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error inesperado: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Editar carro"), backgroundColor: Colors.blueAccent),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              fechaCampo("Fecha entrada", fechaEntradaCtrl),
              horaCampo("Hora entrada", horaEntradaCtrl),
              dropdownCampo("Vehículo", vehiculoSeleccionado, listaVehiculos,
                  (val) => setState(() => vehiculoSeleccionado = val)),
              dropdownCampo("Categoría", categoriaSeleccionada, listaCategorias,
                  (val) => setState(() => categoriaSeleccionada = val)),
              campoTexto("Placas", placasCtrl, validator: "Placas obligatorias"),
              const Divider(height: 40),
              fechaCampo("Fecha salida", fechaSalidaCtrl),
              horaCampo("Hora salida", horaSalidaCtrl),
              campoTexto("Tiempo total", tiempoCtrl, read: true),
              campoTexto("Tarifa total", tarifaCtrl, read: true),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, padding: const EdgeInsets.all(16)),
                onPressed: guardarSalida,
                child: const Text("Guardar cambios", style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget fechaCampo(String label, TextEditingController ctrl) => Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: TextFormField(
          readOnly: true,
          controller: ctrl,
          validator: (v) => v == null || v.isEmpty ? "Fecha obligatoria" : null,
          onTap: () => pickFecha(ctrl),
          decoration: InputDecoration(
            labelText: label,
            suffixIcon: const Icon(Icons.calendar_today),
            border: const OutlineInputBorder(),
          ),
        ),
      );

  Widget horaCampo(String label, TextEditingController ctrl) => Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: TextFormField(
          readOnly: true,
          controller: ctrl,
          validator: (v) => v == null || v.isEmpty ? "Hora obligatoria" : null,
          onTap: () => pickHora(ctrl),
          decoration: InputDecoration(
            labelText: label,
            suffixIcon: const Icon(Icons.access_time),
            border: const OutlineInputBorder(),
          ),
        ),
      );

  Widget campoTexto(String label, TextEditingController ctrl,
          {bool read = false, String? validator}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: TextFormField(
          controller: ctrl,
          readOnly: read,
          validator: validator != null ? (v) => v == null || v.isEmpty ? validator : null : null,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
        ),
      );

  Widget dropdownCampo(String label, String? valor, List<String> lista, Function(String?) onChanged) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: DropdownButtonFormField<String>(
          value: valor,
          items: lista.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
          validator: (v) => v == null || v.isEmpty ? "$label obligatorio" : null,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
        ),
      );
}
