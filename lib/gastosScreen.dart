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

    List<Categoria> categoriasOrdenadas = List.from(estadoCategorias.categorias);
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

    // double totalMonto;
    // if (selectedVehiculoId == 0 && selectedCategoriaId == 0) {
    //   totalMonto =
    //       estadoGastos.gastos.fold(0.0, (sum, gasto) => sum + gasto.monto);
    // } else if (selectedVehiculoId != 0 && selectedCategoriaId == 0) {
    //   totalMonto = estadoGastos.gastos
    //       .where((gasto) => gasto.vehiculoId == selectedVehiculoId)
    //       .fold(0.0, (sum, gasto) => sum + gasto.monto);
    // } else if (selectedVehiculoId == 0 && selectedCategoriaId != 0) {
    //   totalMonto = estadoGastos.gastos
    //       .where((gasto) => gasto.categoriaId == selectedCategoriaId)
    //       .fold(0.0, (sum, gasto) => sum + gasto.monto);
    // } else {
    //   totalMonto = estadoGastos.gastos
    //       .where((gasto) =>
    //           gasto.vehiculoId == selectedVehiculoId &&
    //           gasto.categoriaId == selectedCategoriaId)
    //       .fold(0.0, (sum, gasto) => sum + gasto.monto);
    // }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF002A52),
        title: Text('Gastos', style: TextStyle(color: Colors.white)),
        actions: [
          PopupMenuButton<String>(
            iconColor: Colors.white,
            onSelected: (value) {
              // Manejar la opción seleccionada
              if (value == 'ver_categorias') {
                _mostrarDialogoVerCategorias(
                    context, categoriasOrdenadas);
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'ver_categorias',
                  child: Text('Ver Categorías'),
                ),
                // Agrega más opciones si es necesario
              ];
            },
          ),
        ],
      ),
      backgroundColor: Color.fromARGB(255, 237, 237, 237),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Total Gastos
          Container(
            margin: EdgeInsets.all(8.0),
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Color(0xCC002A52),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Gastos',
                  style: TextStyle(color: Colors.white, fontSize: 18.0),
                ),
                SizedBox(height: 8.0),
                Text(
                  '\$$totalMonto',
                  style: TextStyle(
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
                margin: EdgeInsets.only(top: 8.0),
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Filtrar por Categoría',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              Card(
                margin: EdgeInsets.only(left: 8.0, right: 8.0),
                elevation: 2,
                child: Container(
                  // margin: EdgeInsets.all(8.0),
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.category, color: Color(0xCC002A52)),
                      SizedBox(width: 8),
                      Expanded(
                        child: DropdownButton<int>(
                          value: selectedCategoriaId,
                          onChanged: (value) {
                            setState(() {
                              selectedCategoriaId = value ?? 0;
                            });
                          },
                          items: [
                            DropdownMenuItem<int>(
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
                margin: EdgeInsets.only(top: 16.0),
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Filtrar por Vehículo',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              Card(
                margin: EdgeInsets.only(left: 8.0, right: 8.0),
                elevation: 2,
                child: Container(
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.directions_car, color: Color(0xCC002A52)),
                      SizedBox(width: 8),
                      Expanded(
                        child: DropdownButton<int>(
                          value: selectedVehiculoId,
                          onChanged: (value) {
                            setState(() {
                              selectedVehiculoId = value ?? 0;
                            });
                          },
                          items: [
                            DropdownMenuItem<int>(
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
              margin: EdgeInsets.all(8.0),
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: estadoGastos.gastos.isEmpty
                  ? Center(
                      child: Text('Agrega un gasto!'),
                    )
                  : ListView.builder(
                      itemCount: filtrarGastos(estadoGastos.gastos,
                              selectedCategoriaId, selectedVehiculoId)
                          .length,
                      itemBuilder: (context, index) {
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
                                icon: Icon(Icons.edit),
                                color: Colors.blueGrey,
                                onPressed: () {
                                  _mostrarDialogoEditarGasto(
                                    context,
                                    gasto,
                                    estadoVehiculos.vehiculos,
                                    estadoCategorias.categorias,
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                color: Colors.red,
                                onPressed: () {
                                  _mostrarDialogoEliminarGasto(
                                    context,
                                    estadoGastos.gastos[index],
                                  );
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
            backgroundColor: Color(0xFF002A52),
            onPressed: () {
              // Acciones para el botón "+Categoria"
              _mostrarDialogoAgregarCategoria(context);
            },
            child: Icon(
              Icons.category,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 16.0), // Espacio entre los dos botones
          FloatingActionButton(
            backgroundColor: Color(0xFF002A52),
            onPressed: () {
              _mostrarDialogoAgregarGasto(context, estadoVehiculos.vehiculos,
                  estadoCategorias.categorias);
            },
            child: Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     _mostrarDialogoAgregarGasto(context, estadoVehiculos.vehiculos);
      //   },
      //   child: Icon(Icons.add),
      // ),
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
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Agregar Gasto',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF002A52),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                    // TextFormField(
                    //   decoration: InputDecoration(labelText: 'Tipo'),
                    //   controller: tipoController,
                    //   validator: (value) {
                    //     if (value == null || value.isEmpty) {
                    //       return 'Este campo no puede estar vacío';
                    //     }
                    //     return null;
                    //   },
                    // ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Monto'),
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
                      decoration: InputDecoration(labelText: 'Fecha'),
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
                      decoration: InputDecoration(labelText: 'Categoria'),
                      value: selectedCategoria,
                      items: categorias.map((Categoria categoria) {
                        return DropdownMenuItem<Categoria>(
                          value: categoria,
                          child: Text('${categoria.nombre}'),
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
                      decoration: InputDecoration(labelText: 'Vehículo'),
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
                      decoration: InputDecoration(labelText: 'Descripción'),
                      controller: descripcionController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Este campo no puede estar vacío';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
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
                                  .showSnackBar(SnackBar(
                                content: Text(
                                  "Gasto agregado!",
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.green,
                              ));
                              Navigator.of(context).pop();
                            } else {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text(
                                  "Por favor, complete todos los campos y seleccione una categoría y un vehículo.",
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.red,
                              ));
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF002A52),
                          ),
                          child: Text(
                            'Guardar',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
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

  void _mostrarDialogoEditarGasto(
    BuildContext context,
    Gasto gasto,
    List<Vehiculo> vehiculos,
    List<Categoria> categorias,
  ) {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
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
    TextEditingController categoriaController = TextEditingController();

    Vehiculo? vehiculoSeleccionado =
        vehiculos.firstWhereOrNull((v) => v.id == gasto.vehiculoId);
    TextEditingController vehiculoController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Editar Gasto',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF002A52),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    // TextFormField(
                    //   decoration: InputDecoration(labelText: 'Tipo'),
                    //   controller: tipoController,
                    //   validator: (value) {
                    //     if (value == null || value.isEmpty) {
                    //       return 'Este campo no puede estar vacío';
                    //     }
                    //     return null;
                    //   },
                    // ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Monto'),
                      controller: montoController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Este campo no puede estar vacío';
                        }
                        return null;
                      },
                    ),
                    DateTimeField(
                      decoration: InputDecoration(labelText: 'Fecha'),
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
                      decoration: InputDecoration(labelText: 'Categoria'),
                      value: selectedCategoria,
                      items: categorias.map((Categoria categoria) {
                        return DropdownMenuItem<Categoria>(
                          value: categoria,
                          child: Text('${categoria.nombre}'),
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
                      decoration: InputDecoration(labelText: 'Vehículo'),
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
                      decoration: InputDecoration(labelText: 'Descripción'),
                      controller: descripcionController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Este campo no puede estar vacío';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
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
                                            categoriaSeleccionada?.id ?? 0,
                                        vehiculoId:
                                            vehiculoSeleccionado?.id ?? 0,
                                      ),
                                    ),
                                  );
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
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
                            backgroundColor: Color(0xFF002A52),
                          ),
                          child: Text(
                            'Guardar',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
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

  void _mostrarDialogoAgregarCategoria(BuildContext context) {
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
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Agregar Categoría',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF002A52),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      decoration:
                          InputDecoration(labelText: 'Nombre de la Categoría'),
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
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              context.read<CategoriasBloc>().add(
                                    AddCategoria(
                                      categoria: Categoria(
                                          nombre:
                                              nombreCategoriaController.text),
                                    ),
                                  );
                              print(
                                  'Categoría agregada: ${nombreCategoriaController.text}');

                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text(
                                  "Categoría agregada!",
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.green,
                              ));
                              Navigator.of(context).pop();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF002A52),
                          ),
                          child: Text(
                            'Guardar',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
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
            margin: EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
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
                          icon: Icon(Icons.delete),
                          color: Colors.red,
                          onPressed: () {
                            _mostrarDialogoEliminarCategoria(
                                context, categoria);
                          },
                        ),
                      )
                  else
                    Padding(
                      padding: const EdgeInsets.all(8.0),
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
          title: Text('Eliminar Gasto'),
          content: Text('¿Estás seguro que deseas eliminar este gasto?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cancelar
              },
              child: Text('Cancelar',
                  style: TextStyle(
                    color: Color(0xFF002A52),
                    fontWeight: FontWeight.bold,
                  )),
            ),
            ElevatedButton(
              onPressed: () {
                // Eliminar el vehículo
                context.read<GastosBloc>().add(
                      DeleteGasto(
                        gasto: gasto,
                      ),
                    );
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Color rojo para indicar peligro
              ),
              child: Text(
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
          title: Text('Eliminar Categoría'),
          content: Text('¿Estás seguro que deseas eliminar esta categoría?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cancelar
              },
              child: Text('Cancelar',
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
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                    "categoria eliminada.",
                    style: TextStyle(color: Colors.white),
                  ),
                  // backgroundColor: Colors.green,
                ));
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Color rojo para indicar peligro
              ),
              child: Text(
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

  // void _mostrarDialogoVerCategorias(BuildContext context, List<Categoria> categorias) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return Dialog(
  //         child: SingleChildScrollView(
  //           child: Container(
  //             padding: EdgeInsets.all(24),
  //             child: Column(
  //               children: [
  //                 for (Categoria categoria in categorias)
  //                   ListTile(
  //                     title: Text(categoria.nombre),
  //                     trailing: IconButton(
  //                       icon: Icon(Icons.delete),
  //                       onPressed: () {
  //                         // Handle delete category action
  //                         context.read<CategoriasBloc>().add(
  //                           DeleteCategoria(
  //                             categoria: categoria,
  //                           ),
  //                         );
  //                         Navigator.of(context).pop(); // Close the dialog
  //                       },
  //                     ),
  //                   ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

//   void _mostrarDialogoAgregarGasto(
//       BuildContext context, List<Vehiculo> vehiculos) {
//     TextEditingController idController = TextEditingController();
//     TextEditingController tipoController = TextEditingController();
//     TextEditingController montoController = TextEditingController();
//     TextEditingController fechaController = TextEditingController(text: DateTime.now().toString());
//     TextEditingController descripcionController = TextEditingController();
//     TextEditingController vehiculoController = TextEditingController();

//     showModalBottomSheet(
//       context: context,
//       builder: (BuildContext context) {
//         return SingleChildScrollView(
//           child: Container(
//             padding: EdgeInsets.all(24),
//             child: Column(
//               children: [
//                 TextField(
//                   decoration: InputDecoration(labelText: 'ID'),
//                   controller: idController,
//                 ),
//                 TextField(
//                   decoration: InputDecoration(labelText: 'Tipo'),
//                   controller: tipoController,
//                 ),
//                 TextField(
//                   decoration: InputDecoration(labelText: 'Monto'),
//                   controller: montoController,
//                 ),
//                 InkWell(
//                   onTap: () async {
//                     DateTime? selectedDate = await showDatePicker(
//                       context: context,
//                       initialDate: DateTime.now(),
//                       firstDate: DateTime(2000),
//                       lastDate: DateTime(2101),
//                     );
//                     if (selectedDate != null) {
//                       fechaController.text = formatDate(selectedDate);
//                     }
//                   },
//                   child: InputDecorator(
//                     decoration: InputDecoration(
//                       labelText: 'Fecha',
//                       hintText: 'Seleccione la fecha',
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(fechaController.text),
//                         Icon(Icons.calendar_today),
//                       ],
//                     ),
//                   ),
//                 ),
//                 DropdownButtonFormField<Vehiculo>(
//                   decoration: InputDecoration(labelText: 'Vehículo'),
//                   value: selectedVehiculo,
//                   items: vehiculos.map((Vehiculo vehiculo) {
//                     return DropdownMenuItem<Vehiculo>(
//                       value: vehiculo,
//                       child: Text('${vehiculo.marca} - ${vehiculo.modelo}'),
//                     );
//                   }).toList(),
//                   onChanged: (Vehiculo? nuevoVehiculo) {
//                     setState(() {
//                       selectedVehiculo = nuevoVehiculo;
//                     });
//                   },
//                   disabledHint: Text(selectedVehiculo != null
//                       ? '${selectedVehiculo!.marca} - ${selectedVehiculo!.modelo}'
//                       : 'Seleccione un vehículo'),
//                 ),
//                 TextField(
//                   decoration: InputDecoration(labelText: 'Descripción'),
//                   controller: descripcionController,
//                 ),
//                 SizedBox(height: 16),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                   children: [
//                     ElevatedButton(
//                       onPressed: () {
//                         context.read<GastosBloc>().add(
//                               AddGasto(
//                                 gasto: Gasto(
//                                   id: int.parse(idController.text),
//                                   tipoGasto: tipoController.text,
//                                   monto: double.parse(montoController.text),
//                                   fecha: DateTime.parse(fechaController.text),
//                                   descripcion: descripcionController.text,
//                                   vehiculoId: selectedVehiculo?.id != null ? selectedVehiculo!.id ?? 0:0
//                                       // : (vehiculoController.text.isNotEmpty
//                                       //     ? (vehiculoController.text
//                                       //                 .split('-')
//                                       //                 .length >
//                                       //             1
//                                       //         ? int.tryParse(vehiculoController
//                                       //                 .text
//                                       //                 .split('-')[1]
//                                       //                 .trim()) ??
//                                       //             0
//                                       //         : 0)
//                                       //     : 0),
//                                 ),
//                                 context: context,
//                               ),
//                             );

//                         Navigator.of(context).pop();
//                       },
//                       child: Text('Guardar'),
//                     ),
//                     TextButton(
//                       onPressed: () {
//                         Navigator.of(context).pop();
//                       },
//                       child: Text('Cancelar'),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   void _mostrarDialogoEditarGasto(
//       BuildContext context, Gasto gasto, List<Vehiculo> vehiculos) {
//     TextEditingController tipoController =
//         TextEditingController(text: gasto.tipoGasto);
//     TextEditingController montoController =
//         TextEditingController(text: gasto.monto.toString());
//     TextEditingController fechaController =
//         TextEditingController(text: formatDate(gasto.fecha));
//     TextEditingController descripcionController =
//         TextEditingController(text: gasto.descripcion);

//     Vehiculo? vehiculoSeleccionado =
//         vehiculos.firstWhereOrNull((v) => v.id == gasto.vehiculoId);
//     TextEditingController vehiculoController = TextEditingController();

//     showModalBottomSheet(
//       context: context,
//       builder: (BuildContext context) {
//         return SingleChildScrollView(
//           child: Container(
//             padding: EdgeInsets.all(24),
//             child: Column(
//               children: [
//                 TextField(
//                   decoration: InputDecoration(labelText: 'Tipo'),
//                   controller: tipoController,
//                 ),
//                 TextField(
//                   decoration: InputDecoration(labelText: 'Monto'),
//                   controller: montoController,
//                 ),
//                 InkWell(
//                   onTap: () async {
//                     DateTime? selectedDate = await showDatePicker(
//                       context: context,
//                       initialDate: gasto.fecha,
//                       firstDate: DateTime(2000),
//                       lastDate: DateTime(2101),
//                     );
//                     if (selectedDate != null) {
//                       fechaController.text = formatDate(selectedDate);
//                     }
//                   },
//                   child: InputDecorator(
//                     decoration: InputDecoration(
//                       labelText: 'Fecha',
//                       hintText: 'Seleccione la fecha',
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(fechaController.text),
//                         Icon(Icons.calendar_today),
//                       ],
//                     ),
//                   ),
//                 ),
//                 DropdownButtonFormField<Vehiculo>(
//                   decoration: InputDecoration(labelText: 'Vehículo'),
//                   value: vehiculoSeleccionado,
//                   items: vehiculos.map((Vehiculo vehiculo) {
//                     return DropdownMenuItem<Vehiculo>(
//                       value: vehiculo,
//                       child: Text('${vehiculo.marca} - ${vehiculo.modelo}'),
//                     );
//                   }).toList(),
//                   onChanged: (Vehiculo? newValue) {
//                     setState(() {
//                       vehiculoController.text =
//                           '${newValue?.marca ?? ''} - ${newValue?.id ?? 0}';
//                     });
//                   },
//                 ),
//                 TextField(
//                   decoration: InputDecoration(labelText: 'Descripción'),
//                   controller: descripcionController,
//                 ),
//                 SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: () {
//                     context.read<GastosBloc>().add(
//                           UpdateGasto(
//                             gasto: Gasto(
//                               id: gasto.id,
//                               tipoGasto: tipoController.text,
//                               monto: double.parse(montoController.text),
//                               fecha: DateTime.parse(fechaController.text),
//                               descripcion: descripcionController.text,
//                               vehiculoId: vehiculoSeleccionado?.id ?? 0,
//                             ),
//                           ),
//                         );

//                     Navigator.of(context).pop();
//                   },
//                   child: Text('Guardar'),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
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
          Text(
            'Total Gastos:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            '\$$totalMonto',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
          ),
        ],
      ),
    );
  }
}
