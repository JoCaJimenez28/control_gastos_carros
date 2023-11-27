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

    double totalMonto;
    if (selectedVehiculoId == 0) {
      totalMonto =
          estadoGastos.gastos.fold(0.0, (sum, gasto) => sum + gasto.monto);
    } else {
      totalMonto = estadoGastos.gastos
          .where((gasto) => gasto.vehiculoId == selectedVehiculoId)
          .fold(0.0, (sum, gasto) => sum + gasto.monto);
    }

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 237, 237, 237),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Total Gastos
          Container(
            margin: EdgeInsets.all(8.0),
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.blue,
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

          // Dropdown for filtering by vehicle
          Container(
            margin: EdgeInsets.all(8.0),
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
            ),
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
                for (var vehiculo in estadoVehiculos.vehiculos)
                  DropdownMenuItem<int>(
                    value: vehiculo.id,
                    child: Text(vehiculo.modelo),
                  ),
              ],
            ),
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
                      child: Text('No hay gastos'),
                    )
                  : ListView.builder(
                      itemCount: estadoGastos.gastos.length,
                      itemBuilder: (context, index) {
                        if (selectedVehiculoId == 0 ||
                            estadoGastos.gastos[index].vehiculoId ==
                                selectedVehiculoId) {
                          return ListTile(
                            title: Text(
                              '${estadoGastos.gastos[index].tipoGasto} - ${estadoGastos.gastos[index].monto}',
                            ),
                            subtitle: Text(
                              'Descripcion: ${estadoGastos.gastos[index].descripcion} - Fecha: ${estadoGastos.gastos[index].fecha}',
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
                                      estadoGastos.gastos[index],
                                      estadoVehiculos.vehiculos,
                                      estadoCategorias.categorias,
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  color: Colors.red,
                                  onPressed: () {
                                    context.read<GastosBloc>().add(
                                          DeleteGasto(
                                            gasto: estadoGastos.gastos[index],
                                          ),
                                        );
                                  },
                                ),
                              ],
                            ),
                          );
                        } else {
                          return SizedBox.shrink();
                        }
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
            onPressed: () {
              // Acciones para el botón "+Categoria"
              _mostrarDialogoAgregarCategoria(context);
            },
            child: Icon(Icons.category),
          ),
          SizedBox(width: 16.0), // Espacio entre los dos botones
          FloatingActionButton(
            onPressed: () {
              _mostrarDialogoAgregarGasto(context, estadoVehiculos.vehiculos,
                  estadoCategorias.categorias);
            },
            child: Icon(Icons.add),
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
    // TextEditingController idController = TextEditingController();
    TextEditingController tipoController = TextEditingController();
    TextEditingController montoController = TextEditingController();
    TextEditingController fechaController =
        TextEditingController(text: DateTime.now().toString());
    TextEditingController descripcionController = TextEditingController();
    TextEditingController categoriaController = TextEditingController();
    TextEditingController vehiculoController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  // TextField(
                  //   decoration: InputDecoration(labelText: 'ID'),
                  //   controller: idController,
                  // ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Agregar Gasto',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
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
                  TextField(
                    decoration: InputDecoration(labelText: 'Tipo'),
                    controller: tipoController,
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: 'Monto'),
                    controller: montoController,
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
                  TextField(
                    decoration: InputDecoration(labelText: 'Descripción'),
                    controller: descripcionController,
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          context.read<GastosBloc>().add(
                                AddGasto(
                                  gasto: Gasto(
                                    // id: int.parse(idController.text),
                                    tipoGasto: tipoController.text,
                                    monto: double.parse(montoController.text),
                                    fecha: DateTime.parse(fechaController.text),
                                    descripcion: descripcionController.text,
                                    categoriaId: selectedCategoria?.id ?? 0,
                                    vehiculoId: selectedVehiculo?.id ?? 0,
                                  ),
                                  context: context,
                                ),
                              );

                          Navigator.of(context).pop();
                        },
                        child: Text('Guardar'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Cancelar',
                          style: TextStyle(
                            // color: Colors.red,
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
        );
      },
    );
  }

  void _mostrarDialogoEditarGasto(BuildContext context, Gasto gasto,
      List<Vehiculo> vehiculos, List<Categoria> categorias) {
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
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
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
                  TextField(
                    decoration: InputDecoration(labelText: 'Tipo'),
                    controller: tipoController,
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: 'Monto'),
                    controller: montoController,
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
                    onSaved: (date) {
                      // Handle when the form is saved
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
                  TextField(
                    decoration: InputDecoration(labelText: 'Descripción'),
                    controller: descripcionController,
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          context.read<GastosBloc>().add(
                                UpdateGasto(
                                  gasto: Gasto(
                                    id: gasto.id,
                                    tipoGasto: tipoController.text,
                                    monto: double.parse(montoController.text),
                                    fecha: DateTime.parse(fechaController.text),
                                    descripcion: descripcionController.text,
                                    categoriaId: categoriaSeleccionada?.id ?? 0,
                                    vehiculoId: vehiculoSeleccionado?.id ?? 0,
                                  ),
                                ),
                              );

                          Navigator.of(context).pop();
                        },
                        child: Text('Guardar'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Cancelar',
                          style: TextStyle(
                            // color: Colors.red,
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
        );
      },
    );
  }

  void _mostrarDialogoAgregarCategoria(BuildContext context) {
    TextEditingController nombreCategoriaController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
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
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
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
                  TextField(
                    decoration:
                        InputDecoration(labelText: 'Nombre de la Categoría'),
                    controller: nombreCategoriaController,
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          context.read<CategoriasBloc>().add(
                                AddCategoria(
                                  categoria: Categoria(
                                      nombre: nombreCategoriaController.text),
                                ),
                              );
                          print(
                              'Categoría agregada: $nombreCategoriaController.text ');

                          Navigator.of(context).pop();
                        },
                        child: Text('Guardar'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Cancelar',
                          style: TextStyle(
                            // color: Colors.red,
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
        );
      },
    );
  }

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
