import 'package:collection/collection.dart';
// import 'package:control_gastos_carros/blocs/gastosBlocPrueba.dart';
import 'package:control_gastos_carros/blocs/gastosBlocDb.dart';
import 'package:control_gastos_carros/blocs/categoriasBlocDb.dart';
import 'package:control_gastos_carros/blocs/vehiculosBlocDb.dart';
import 'package:control_gastos_carros/modelos/categorias.dart';
import 'package:control_gastos_carros/modelos/gastos.dart';
import 'package:control_gastos_carros/modelos/vehiculos.dart';
import 'package:datetime_picker_formfield_new/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class GastosScreen extends StatefulWidget {
  @override
  State<GastosScreen> createState() => _GastosScreenState();
}

class _GastosScreenState extends State<GastosScreen> {
  int selectedVehiculoId = 0; // "Todos"
  int selectedCategoriaId = 0; // "Todos"
  Vehiculo? selectedVehiculo;
  Categoria? selectedCategoria;

  @override
  void initState() {
    super.initState();
    context.read<VehiculosBlocDb>().add(VehiculosInicializado());
    context.read<CategoriasBloc>().add(Categoriasinicializado());
  }

  @override
  Widget build(BuildContext context) {
    var estadoGastos = context.watch<GastosBloc>().state;
    var estadoVehiculos = context.watch<VehiculosBlocDb>().state;
    var estadoCategorias = context.watch<CategoriasBloc>().state;

    print('BlocBuilder reconstruido. Nuevo estadoGastos: $estadoGastos');
    print('BlocBuilder reconstruido. Nuevo estadoCats: $estadoCategorias');

    List<Categoria> categoriasOrdenadas =
        List.from(estadoCategorias.categorias);
    categoriasOrdenadas.sort((a, b) => a.nombre.compareTo(b.nombre));

    List<Vehiculo> vehiculosOrdenados = List.from(estadoVehiculos.vehiculos);
    vehiculosOrdenados.sort((a, b) => a.modelo.compareTo(b.modelo));

//     List<Gasto> gastosOrdenados = List.from(estadoGastos.gastos);
// gastosOrdenados.removeWhere((gasto) => gasto.vehiculoId == null);
// gastosOrdenados.sort((a, b) => a.nombre.compareTo(b.nombre));

    double totalMonto;

    if (selectedVehiculoId == 0 && selectedCategoriaId == 0) {
      totalMonto =
          estadoGastos.gastos.fold(0.0, (sum, gasto) => sum + gasto.monto);
    } else if (selectedVehiculoId != 0 && selectedCategoriaId == 0) {
      totalMonto = estadoGastos.gastos
          .where((gasto) => gasto.vehiculoId == selectedVehiculoId)
          .fold(0.0, (sum, gasto) => sum + gasto.monto);
    } else if (selectedVehiculoId == 0 && selectedCategoriaId != 0) {
      totalMonto = estadoGastos.gastos
          .where((gasto) => gasto.categoriaId == selectedCategoriaId)
          .fold(0.0, (sum, gasto) => sum + gasto.monto);
    } else {
      totalMonto = estadoGastos.gastos
          .where((gasto) =>
              gasto.vehiculoId == selectedVehiculoId &&
              gasto.categoriaId == selectedCategoriaId)
          .fold(0.0, (sum, gasto) => sum + gasto.monto);
    }
    context.read<GastosBloc>().add(GastosInicializado());
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF002A52),
        title: const Text('Gastos', style: TextStyle(color: Colors.white)),
        actions: [
          PopupMenuButton<String>(
            iconColor: Colors.white,
            onSelected: (value) {
              if (value == 'ver_categorias') {
                _mostrarDialogoVerCategorias(context, categoriasOrdenadas);
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'ver_categorias',
                  child: Text('Ver Categorías'),
                ),
              ];
            },
          ),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 237, 237, 237),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Total Gastos
          Container(
            margin: const EdgeInsets.all(8.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: const Color(0xCC002A52),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Gastos',
                  style: TextStyle(color: Colors.white, fontSize: 18.0),
                ),
                const SizedBox(height: 8.0),
                Text(
                  '\$$totalMonto',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Filtrar por categoria
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8.0),
                padding: const EdgeInsets.all(8.0),
                child: const Text(
                  'Filtrar por Categoría',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              Card(
                margin: const EdgeInsets.only(left: 8.0, right: 8.0),
                elevation: 2,
                child: Container(
                  // margin: EdgeInsets.all(8.0),
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.category, color: Color(0xCC002A52)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButton<int>(
                          value: selectedCategoriaId,
                          onChanged: (value) {
                            setState(() {
                              selectedCategoriaId = value ?? 0;
                            });
                          },
                          items: [
                            const DropdownMenuItem<int>(
                              value: 0,
                              child: Text('Todos'),
                            ),
                            for (var categoria in categoriasOrdenadas)
                              DropdownMenuItem<int>(
                                value: categoria.id,
                                child: Text(categoria.nombre),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 16.0),
                padding: const EdgeInsets.all(8.0),
                child: const Text(
                  'Filtrar por Vehículo',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              Card(
                margin: const EdgeInsets.only(left: 8.0, right: 8.0),
                elevation: 2,
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.directions_car,
                          color: Color(0xCC002A52)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButton<int>(
                          value: selectedVehiculoId,
                          onChanged: (value) {
                            setState(() {
                              selectedVehiculoId = value ?? 0;
                            });
                          },
                          items: [
                            const DropdownMenuItem<int>(
                              value: 0,
                              child: Text('Todos'),
                            ),
                            for (var vehiculo in vehiculosOrdenados)
                              DropdownMenuItem<int>(
                                value: vehiculo.id,
                                child: Text(vehiculo.modelo),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Lista de Gastos
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(8.0),
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: estadoGastos.gastos.isEmpty
                  ? const Center(
                      child: Text('Agrega un gasto!'),
                    )
                  : ListView.builder(
                      itemCount: filtrarGastos(estadoGastos.gastos,
                              selectedCategoriaId, selectedVehiculoId)
                          .length,
                      itemBuilder: (context, index) {
                        // var nuevoEstadoGastos = context.watch<GastosBloc>().state;

                        print('NewestadiGastos: ${estadoGastos.gastos}');
                        var gastosFiltrados = filtrarGastos(estadoGastos.gastos,
                            selectedCategoriaId, selectedVehiculoId);
                        var gasto = gastosFiltrados[index];
                        print('gastosFiltrados: $gastosFiltrados');
                        // totalMonto = totalMonto + gastosFiltrados[index].monto;

                        // Buscar la categoría correspondiente al gasto
                        Categoria? categoriaDelGasto = estadoCategorias
                            .categorias
                            .firstWhereOrNull((categoria) =>
                                categoria.id == gasto.categoriaId);

                        // Buscar el vehículo correspondiente al gasto
                        Vehiculo? vehiculoDelGasto = estadoVehiculos.vehiculos
                            .firstWhereOrNull(
                                (vehiculo) => vehiculo.id == gasto.vehiculoId);

                        return ListTile(
                          title: Text(
                            '${categoriaDelGasto?.nombre ?? 'Sin categoría'} \$${gasto.monto}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Vehiculo: ${vehiculoDelGasto?.modelo} \nFecha: ${DateFormat("dd-MM-yyyy").format(gasto.fecha)} \nDescripcion: ${gasto.descripcion}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                color: Colors.blueGrey,
                                onPressed: () {
                                  _mostrarDialogoEditarGasto(
                                    context,
                                    gasto,
                                    vehiculosOrdenados,
                                    categoriasOrdenadas,
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                color: Colors.red,
                                onPressed: () {
                                  _mostrarDialogoEliminarGasto(context, gasto);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            backgroundColor: const Color(0xFF002A52),
            onPressed: () {
              _mostrarDialogoAgregarCategoria(context, estadoCategorias);
              // estadoCategorias = context.watch<CategoriasBloc>().state;
              print('error cat: ${estadoCategorias.error}');
              if (estadoCategorias.error != "") {
                  estadoCategorias.error = "";
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(estadoCategorias.error),
                      backgroundColor: Colors.red,
                    ),
                  );
              }
            },
            child: const Icon(
              Icons.category,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16.0),
          FloatingActionButton(
            backgroundColor: const Color(0xFF002A52),
            onPressed: () {
              _mostrarDialogoAgregarGasto(
                  context, vehiculosOrdenados, categoriasOrdenadas);
            },
            child: const Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  void _mostrarDialogoAgregarGasto(BuildContext context,
      List<Vehiculo> vehiculos, List<Categoria> categorias) {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    TextEditingController tipoController = TextEditingController();
    TextEditingController montoController = TextEditingController();
    TextEditingController fechaController =
        TextEditingController(text: DateTime.now().toString());
    TextEditingController descripcionController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Agregar Gasto',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF002A52),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Monto'),
                      controller: montoController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Este campo no puede estar vacío';
                        }

                        RegExp numerosConDecimales = RegExp(r'^\d*\.?\d*$');
                        RegExp contieneLetras = RegExp(r'[a-zA-Z]');

                        if (contieneLetras.hasMatch(value)) {
                          return 'Solo se permiten números';
                        }

                        if (!numerosConDecimales.hasMatch(value)) {
                          return 'Ingrese un número válido';
                        }
                        return null;
                      },
                    ),
                    DateTimeField(
                      decoration: const InputDecoration(labelText: 'Fecha'),
                      format: DateFormat("yyyy-MM-dd"),
                      initialValue: DateTime.now(),
                      onChanged: (date) {
                        setState(() {
                          var selectedDate = date!;
                          fechaController.text = formatDate(selectedDate);
                        });
                      },
                      onShowPicker: (context, currentValue) async {
                        final date = await showDatePicker(
                          context: context,
                          firstDate: DateTime.utc(DateTime.now().year),
                          lastDate: DateTime.now(),
                          initialDate: currentValue ?? DateTime.now(),
                        );

                        if (date != null) {
                          currentValue = DateTime.now();
                        }

                        return date;
                      },
                    ),
                    DropdownButtonFormField<Categoria>(
                      decoration: const InputDecoration(labelText: 'Categoria'),
                      value: selectedCategoria,
                      items: categorias.map((Categoria categoria) {
                        return DropdownMenuItem<Categoria>(
                          value: categoria,
                          child: Text(categoria.nombre),
                        );
                      }).toList(),
                      onChanged: (Categoria? nuevaCategoria) {
                        setState(() {
                          selectedCategoria = nuevaCategoria;
                        });
                      },
                      disabledHint: Text(selectedCategoria != null
                          ? '${selectedCategoria!.nombre} '
                          : 'Seleccione una categoria'),
                    ),
                    DropdownButtonFormField<Vehiculo>(
                      decoration: const InputDecoration(labelText: 'Vehículo'),
                      value: selectedVehiculo,
                      items: vehiculos.map((Vehiculo vehiculo) {
                        return DropdownMenuItem<Vehiculo>(
                          value: vehiculo,
                          child: Text('${vehiculo.marca} - ${vehiculo.modelo}'),
                        );
                      }).toList(),
                      onChanged: (Vehiculo? nuevoVehiculo) {
                        setState(() {
                          selectedVehiculo = nuevoVehiculo;
                        });
                      },
                      disabledHint: Text(selectedVehiculo != null
                          ? '${selectedVehiculo!.marca} - ${selectedVehiculo!.modelo}'
                          : 'Seleccione un vehículo'),
                    ),
                    TextFormField(
                      decoration:
                          const InputDecoration(labelText: 'Descripción'),
                      controller: descripcionController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Este campo no puede estar vacío';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate() &&
                                selectedCategoria != null &&
                                selectedVehiculo != null) {
                              context.read<GastosBloc>().add(
                                    AddGasto(
                                      gasto: Gasto(
                                        tipoGasto: tipoController.text,
                                        monto:
                                            double.parse(montoController.text),
                                        fecha: DateTime.parse(
                                            fechaController.text),
                                        descripcion: descripcionController.text,
                                        categoriaId: selectedCategoria!.id!,
                                        vehiculoId: selectedVehiculo!.id!,
                                      ),
                                      context: context,
                                    ),
                                  );
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text(
                                  "Gasto agregado!",
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.green,
                              ));
                              Navigator.of(context).pop();
                            } else {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text(
                                  "Por favor, complete todos los campos y seleccione una categoría y un vehículo.",
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.red,
                              ));
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF002A52),
                          ),
                          child: const Text(
                            'Guardar',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red),
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _mostrarDialogoEditarGasto(
    BuildContext context,
    Gasto gasto,
    List<Vehiculo> vehiculos,
    List<Categoria> categorias,
  ) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    TextEditingController tipoController =
        TextEditingController(text: gasto.tipoGasto);
    TextEditingController montoController =
        TextEditingController(text: gasto.monto.toString());
    TextEditingController fechaController =
        TextEditingController(text: formatDate(gasto.fecha));
    TextEditingController descripcionController =
        TextEditingController(text: gasto.descripcion);

    Categoria? categoriaSeleccionada =
        categorias.firstWhereOrNull((v) => v.id == gasto.categoriaId);

    Vehiculo? vehiculoSeleccionado =
        vehiculos.firstWhere((v) => v.id == gasto.vehiculoId);
    TextEditingController vehiculoController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Editar Gasto',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF002A52),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Monto'),
                      controller: montoController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Este campo no puede estar vacío';
                        }
                        return null;
                      },
                    ),
                    DateTimeField(
                      decoration: const InputDecoration(labelText: 'Fecha'),
                      format: DateFormat("yyyy-MM-dd"),
                      initialValue: DateTime.now(),
                      onChanged: (date) {
                        setState(() {
                          var selectedDate = date!;
                          fechaController.text = formatDate(selectedDate);
                        });
                      },
                      onShowPicker: (context, currentValue) async {
                        final date = await showDatePicker(
                          context: context,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                          initialDate: currentValue ?? DateTime.now(),
                        );

                        if (date != null) {
                          currentValue = DateTime.now();
                        }

                        return date;
                      },
                    ),
                    DropdownButtonFormField<Categoria>(
                      decoration: const InputDecoration(labelText: 'Categoria'),
                      value: selectedCategoria,
                      items: categorias.map((Categoria categoria) {
                        return DropdownMenuItem<Categoria>(
                          value: categoria,
                          child: Text(categoria.nombre),
                        );
                      }).toList(),
                      onChanged: (Categoria? nuevaCategoria) {
                        setState(() {
                          selectedCategoria = nuevaCategoria;
                        });
                      },
                      disabledHint: Text(selectedCategoria != null
                          ? '${selectedCategoria!.nombre} '
                          : 'Seleccione una categoria'),
                    ),
                    DropdownButtonFormField<Vehiculo>(
                      decoration: const InputDecoration(labelText: 'Vehículo'),
                      value: vehiculoSeleccionado,
                      items: vehiculos.map((Vehiculo vehiculo) {
                        return DropdownMenuItem<Vehiculo>(
                          value: vehiculo,
                          child: Text('${vehiculo.marca} - ${vehiculo.modelo}'),
                        );
                      }).toList(),
                      onChanged: (Vehiculo? newValue) {
                        setState(() {
                          vehiculoController.text =
                              '${newValue?.marca ?? ''} - ${newValue?.id ?? 0}';
                        });
                      },
                    ),
                    TextFormField(
                      decoration:
                          const InputDecoration(labelText: 'Descripción'),
                      controller: descripcionController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Este campo no puede estar vacío';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              context.read<GastosBloc>().add(
                                    UpdateGasto(
                                      gasto: Gasto(
                                        id: gasto.id,
                                        tipoGasto: tipoController.text,
                                        monto:
                                            double.parse(montoController.text),
                                        fecha: DateTime.parse(
                                            fechaController.text),
                                        descripcion: descripcionController.text,
                                        categoriaId:
                                            selectedCategoria?.id ?? 0,
                                        vehiculoId:
                                            vehiculoSeleccionado.id ?? 0,
                                      ),
                                    ),
                                  );
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text(
                                  "Gasto editado!",
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.green,
                              ));
                              Navigator.of(context).pop();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF002A52),
                          ),
                          child: const Text(
                            'Guardar',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red),
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _mostrarDialogoAgregarCategoria(
      BuildContext context, CategoriasEstado estadoCategorias) {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    TextEditingController nombreCategoriaController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Agregar Categoría',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF002A52),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                          labelText: 'Nombre de la Categoría'),
                      controller: nombreCategoriaController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Este campo no puede estar vacío';
                        }

                        final RegExp caracteresEspeciales =
                            RegExp(r'[!@#%^&*(),.?":{}|<>0-9]');
                        if (caracteresEspeciales.hasMatch(value)) {
                          return 'No se permiten caracteres especiales ni números';
                        }

                        // Validar que la placa no sea igual a otras registradas
                        final estado = context.read<CategoriasBloc>();
                        final categorias = estado.state.categorias;
                        final categoriaExiste = categorias.any(
                          (categoria) =>
                              categoria.nombre ==
                              value.trim(),
                        );

                        if (categoriaExiste) return 'Esta categoría ya existe.';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            String nombreSinEspacios =
                                  nombreCategoriaController.text.trim();
                            if (_formKey.currentState!.validate()) {
                              context.read<CategoriasBloc>().add(
                                    AddCategoria(
                                      categoria: Categoria(
                                          nombre: nombreSinEspacios
                                        ),
                                    ),
                                  );
                              // print(
                              //     'Categoría agregada: ${nombreCategoriaController.text}');
                              // ScaffoldMessenger.of(context)
                              //     .showSnackBar(const SnackBar(
                              //   content: Text(
                              //     "Categoría agregada!",
                              //     style: TextStyle(color: Colors.white),
                              //   ),
                              //   backgroundColor: Colors.green,
                              // ));
                              Navigator.of(context).pop();
                            }
                            // if(estadoCategorias != "") print("entro al if con error");
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF002A52),
                          ),
                          child: const Text(
                            'Guardar',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _mostrarDialogoVerCategorias(
      BuildContext context, List<Categoria> categorias) {
    print(categorias);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            margin: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Categorias',
                      style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF002A52)),
                    ),
                  ),
                  if (categorias.isNotEmpty)
                    for (Categoria categoria in categorias)
                      ListTile(
                        title: Text(categoria.nombre),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          color: Colors.red,
                          onPressed: () {
                            _mostrarDialogoEliminarCategoria(
                                context, categoria);
                          },
                        ),
                      )
                  else
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Agrega una categoría',
                        style: TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Gasto> filtrarGastos(
      List<Gasto> todosLosGastos, int categoriaId, int vehiculoId) {
    if (categoriaId == 0 && vehiculoId == 0) {
      // Mostrar todos los gastos si no hay filtros aplicados
      return todosLosGastos;
    } else if (categoriaId == 0) {
      // Filtrar por vehículo si la categoría es "Todos"
      return todosLosGastos
          .where((gasto) => gasto.vehiculoId == vehiculoId)
          .toList();
    } else if (vehiculoId == 0) {
      // Filtrar por categoría si el vehículo es "Todos"
      return todosLosGastos
          .where((gasto) => gasto.categoriaId == categoriaId)
          .toList();
    } else {
      // Filtrar por ambos: categoría y vehículo
      return todosLosGastos
          .where((gasto) =>
              gasto.categoriaId == categoriaId &&
              gasto.vehiculoId == vehiculoId)
          .toList();
    }
  }

  void _mostrarDialogoEliminarGasto(BuildContext context, Gasto gasto) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('¿Eliminar éste gasto?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          content: const Text('El gasto se eliminará permanentemente'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar',
                  style: TextStyle(
                    color: Color(0xFF002A52),
                    fontWeight: FontWeight.bold,
                  )),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<GastosBloc>().add(
                      DeleteGasto(
                        gasto: gasto,
                      ),
                    );
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text(
                'Aceptar',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _mostrarDialogoEliminarCategoria(
      BuildContext context, Categoria categoria) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('¿Eliminar ésta categoría?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          content: const Text('La categoría se eliminará permanentemente'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar',
                  style: TextStyle(
                    color: Color(0xFF002A52),
                    fontWeight: FontWeight.bold,
                  )),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<CategoriasBloc>().add(
                      DeleteCategoria(
                        categoria: categoria,
                      ),
                    );
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text(
                    "categoria eliminada.",
                    style: TextStyle(color: Colors.white),
                  ),
                ));
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text(
                'Aceptar',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class TotalGastosWidget extends StatelessWidget {
  final double totalMonto;
  const TotalGastosWidget({Key? key, required this.totalMonto})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Total Gastos:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            '\$$totalMonto',
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
          ),
        ],
      ),
    );
  }
}
