import 'package:control_gastos_carros/blocs/vehiculosBlocDb.dart';
import 'package:control_gastos_carros/modelos/vehiculos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:datetime_picker_formfield_new/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';

class VehiculosScreen extends StatefulWidget {
  @override
  State<VehiculosScreen> createState() => _VehiculosScreenState();
}

class _VehiculosScreenState extends State<VehiculosScreen> {
  final RegExp caracteresEspeciales = RegExp(r'[!@#%^&*(),.?":{}|<>0-9]');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF002A52),
        title: Text('vehiculos', style: TextStyle(color: Colors.white)),
      ),
      backgroundColor: Color.fromARGB(255, 237, 237, 237),
      body: BlocBuilder<VehiculosBlocDb, VehiculoEstado>(
        builder: (context, state) {
          var estado = context.watch<VehiculosBlocDb>().state;
          print('BlocBuilder reconstruido. Nuevo estado: $estado');

          // Check if there is an error
          if (state.error.isNotEmpty) {
            // Show Snackbar for the error
            _mostrarSnackBar(state.error);
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Número total de autos
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
                      'Total de Autos',
                      style: TextStyle(color: Colors.white, fontSize: 18.0),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      '${estado.vehiculos.length}',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              // Lista de vehículos
              Expanded(
                child: Container(
                  margin: EdgeInsets.all(8.0),
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: estado.vehiculos.isEmpty
                      ? Center(
                          child: Text('No hay vehículos'),
                        )
                      : ListView.builder(
                          itemCount: estado.vehiculos.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(
                                '${estado.vehiculos[index].modelo} - ${estado.vehiculos[index].placa}',
                              ),
                              subtitle: Text(
                                'Año: ${estado.vehiculos[index].anio} - Marca: ${estado.vehiculos[index].marca} - Color: ${estado.vehiculos[index].color}',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    color: Colors.blueGrey,
                                    onPressed: () {
                                      _mostrarDialogoEditarVehiculo(
                                        context,
                                        estado.vehiculos[index],
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    color: Colors.red,
                                    onPressed: () {
                                      _mostrarDialogoEliminarVehiculo(
                                        context,
                                        estado.vehiculos[index],
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
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF002A52),
        onPressed: () {
          _mostrarDialogoAgregarVehiculo(context);
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  String formatYearDate(DateTime date) {
    return DateFormat('yyyy').format(date);
  }

  void _mostrarDialogoAgregarVehiculo(BuildContext context) {
    GlobalKey<FormState> formKey = GlobalKey<FormState>();
    TextEditingController marcaController = TextEditingController();
    TextEditingController placaController = TextEditingController();
    TextEditingController modeloController = TextEditingController();
    TextEditingController anioController =
        TextEditingController(text: DateTime.now().year.toString());
    TextEditingController colorController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Nuevo Vehículo',
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
                      decoration: InputDecoration(labelText: 'Marca'),
                      controller: marcaController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Este campo no puede estar vacío';
                        }

                        // Verificar que no contiene caracteres especiales o números
                        // final RegExp caracteresEspeciales = RegExp(r'[!@#%^&*(),.?":{}|<>0-9]');
                        if (caracteresEspeciales.hasMatch(value)) {
                          return 'No se permiten caracteres especiales ni números';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Placa'),
                      controller: placaController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Este campo no puede estar vacío';
                        }
                        // Validación de formato de placa
                        final placaPattern = RegExp(r'^[A-Z]{3}-\d{4}$');
                        if (!placaPattern.hasMatch(value.toUpperCase())) {
                          return 'Formato de placa inválido';
                        }

                        // Validar que la placa no sea igual a otras registradas
                        final estado = context.read<VehiculosBlocDb>();
                        final vehiculos = estado.state.vehiculos;
                        final placaExiste = vehiculos.any(
                          (vehiculo) =>
                              vehiculo.placa.toUpperCase() ==
                              value.toUpperCase(),
                        );

                        if(placaExiste) return 'Esta placa ya esta registrada';
                        return null;
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Modelo'),
                      controller: modeloController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Este campo no puede estar vacío';
                        }

                        // Verificar que no contiene caracteres especiales o números
                        final RegExp caracteresEspecialesSinNumeros =
                            RegExp(r'[!@#%^&*(),.?":{}|<>]');
                        if (caracteresEspecialesSinNumeros.hasMatch(value)) {
                          return 'No se permiten caracteres especiales';
                        }
                        return null;
                      },
                    ),
                    DateTimeField(
                      decoration: InputDecoration(labelText: 'Año'),
                      controller: anioController,
                      format: DateFormat("yyyy"),
                      initialValue: DateTime.now(),
                      onChanged: (date) {
                        print('date: $date');
                        setState(() {
                          if (date != null) {
                            var selectedDate = date;
                            anioController.text =
                                DateFormat("yyyy").format(selectedDate);
                          }
                        });
                      },
                      onShowPicker: (context, currentValue) async {
                        print('current $currentValue');
                        final date = await showDialog<DateTime>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Seleccione un Año'),
                              content: Container(
                                height: 200,
                                width: 200,
                                child: YearPicker(
                                  firstDate: DateTime(1950),
                                  lastDate: DateTime.now(),
                                  selectedDate: currentValue ?? DateTime.now(),
                                  onChanged: (DateTime value) {
                                    setState(() {
                                      currentValue = value;
                                      anioController.text =
                                          DateFormat("yyyy").format(value);
                                      print(
                                          'controller ${anioController.text}');
                                      Navigator.of(context).pop();
                                    });
                                  },
                                ),
                              ),
                            );
                          },
                        );

                        return date;
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Color'),
                      controller: colorController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Este campo no puede estar vacío';
                        }

                        // Verificar que no contiene caracteres especiales o números
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
                            try {
                              context.read<VehiculosBlocDb>().add(
                                    AddVehiculo(
                                      vehiculo: Vehiculo(
                                        placa:
                                            placaController.text.toUpperCase(),
                                        marca: marcaController.text,
                                        modelo: modeloController.text,
                                        anio: anioController.text,
                                        color: colorController.text,
                                      ),
                                    ),
                                  );
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text(
                                  "vehiculo agregado!",
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.green,
                              ));
                              Navigator.of(context).pop();
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    e.toString(),
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
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
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'Cancelar',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
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

  void _mostrarDialogoEditarVehiculo(BuildContext context, Vehiculo vehiculo) {
    GlobalKey<FormState> formKey = GlobalKey<FormState>();
    TextEditingController marcaController =
        TextEditingController(text: vehiculo.marca);
    TextEditingController placaController =
        TextEditingController(text: vehiculo.placa);
    TextEditingController modeloController =
        TextEditingController(text: vehiculo.modelo);
    TextEditingController anioController =
        TextEditingController(text: vehiculo.anio);
    TextEditingController colorController =
        TextEditingController(text: vehiculo.color);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Editar Vehículo',
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
                      decoration: InputDecoration(labelText: 'ID'),
                      controller:
                          TextEditingController(text: vehiculo.id.toString()),
                      enabled: false,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Marca'),
                      controller: marcaController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Este campo no puede estar vacío';
                        }

                        // Verificar que no contiene caracteres especiales o números
                        if (caracteresEspeciales.hasMatch(value)) {
                          return 'No se permiten caracteres especiales ni números';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Placa'),
                      controller: placaController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Este campo no puede estar vacío';
                        }
                        // Validación de formato de placa
                        final formatoPlaca = RegExp(r'^[A-Z]{3}-\d{4}$');
                        print('placa ${value.toUpperCase()}');
                        if (!formatoPlaca.hasMatch(value.toUpperCase())) {
                          return 'Formato de placa inválido';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Modelo'),
                      controller: modeloController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Este campo no puede estar vacío';
                        }
                        final RegExp caracteresEspecialesSinNumeros =
                            RegExp(r'[!@#%^&*(),.?":{}|<>]');
                        if (caracteresEspecialesSinNumeros.hasMatch(value)) {
                          return 'No se permiten caracteres especiales ni números';
                        }

                        return null;
                      },
                    ),
                    DateTimeField(
                      decoration: InputDecoration(labelText: 'Año'),
                      controller: anioController,
                      format: DateFormat("yyyy"),
                      initialValue: DateTime.now(),
                      onChanged: (date) {
                        print('date: $date');
                        setState(() {
                          if (date != null) {
                            var selectedDate = date;
                            anioController.text =
                                DateFormat("yyyy").format(selectedDate);
                          }
                        });
                      },
                      onShowPicker: (context, currentValue) async {
                        print('current $currentValue');
                        final date = await showDialog<DateTime>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Seleccione un Año'),
                              content: Container(
                                height: 200,
                                width: 200,
                                child: YearPicker(
                                  firstDate: DateTime(1950),
                                  lastDate: DateTime.now(),
                                  selectedDate: currentValue ?? DateTime.now(),
                                  onChanged: (DateTime value) {
                                    setState(() {
                                      currentValue = value;
                                      anioController.text =
                                          DateFormat("yyyy").format(value);
                                      print(
                                          'controller ${anioController.text}');
                                      Navigator.of(context).pop();
                                    });
                                  },
                                ),
                              ),
                            );
                          },
                        );

                        return date;
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Color'),
                      controller: colorController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Este campo no puede estar vacío';
                        }

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
                            try {
                              context.read<VehiculosBlocDb>().add(
                                    UpdateVehiculo(
                                      vehiculo: Vehiculo(
                                        id: vehiculo.id,
                                        placa:
                                            placaController.text.toUpperCase(),
                                        marca: marcaController.text,
                                        modelo: modeloController.text,
                                        anio: anioController.text,
                                        color: colorController.text,
                                      ),
                                    ),
                                  );
                              var estado = context.watch<VehiculosBlocDb>().state; 
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text(
                                  estado.error != "" ? estado.error : "vehiculo actualizado!",
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: estado.error != "" ? Colors.red : Colors.green,
                              ));
                              Navigator.of(context).pop();
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    e.toString(),
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
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
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'Cancelar',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
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

  // void _mostrarDialogoEditarVehiculo(BuildContext context, Vehiculo vehiculo) {
  //   TextEditingController marcaController =
  //       TextEditingController(text: vehiculo.marca);
  //   TextEditingController placaController =
  //       TextEditingController(text: vehiculo.placa);
  //   TextEditingController modeloController =
  //       TextEditingController(text: vehiculo.modelo);
  //   TextEditingController anioController =
  //       TextEditingController(text: vehiculo.anio);
  //   TextEditingController colorController =
  //       TextEditingController(text: vehiculo.color);

  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return Dialog(
  //         child: SingleChildScrollView(
  //           child: Container(
  //             padding: EdgeInsets.all(24),
  //             child: Column(
  //               children: [
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                   children: [
  //                     Text(
  //                       'Editar Vehículo',
  //                       style: TextStyle(
  //                         fontSize: 20,
  //                         fontWeight: FontWeight.bold,
  //                         color: Color(0xFF002A52),
  //                       ),
  //                     ),
  //                     IconButton(
  //                       icon: Icon(Icons.close),
  //                       onPressed: () {
  //                         Navigator.of(context).pop();
  //                       },
  //                     ),
  //                   ],
  //                 ),
  //                 SizedBox(height: 16),
  //                 TextField(
  //                   decoration: InputDecoration(labelText: 'ID'),
  //                   controller:
  //                       TextEditingController(text: vehiculo.id.toString()),
  //                   enabled: false,
  //                 ),
  //                 TextField(
  //                   decoration: InputDecoration(labelText: 'Marca'),
  //                   controller: marcaController,
  //                 ),
  //                 TextField(
  //                   decoration: InputDecoration(labelText: 'Placa'),
  //                   controller: placaController,
  //                 ),
  //                 TextField(
  //                   decoration: InputDecoration(labelText: 'Modelo'),
  //                   controller: modeloController,
  //                 ),
  //                 // TextField(
  //                 //   decoration: InputDecoration(labelText: 'Año'),
  //                 //   controller: anioController,
  //                 // ),
  //                  DateTimeField(
  //                   decoration: InputDecoration(labelText: 'Año'),
  //                   controller: anioController,
  //                   format: DateFormat("yyyy"),
  //                   initialValue: DateTime.now(),
  //                   onChanged: (date) {
  //                     print('date: $date');
  //                     setState(() {
  //                       if (date != null) {
  //                         var selectedDate = date;
  //                         anioController.text = DateFormat("yyyy").format(selectedDate);
  //                       }
  //                     });
  //                   },
  //                   onShowPicker: (context, currentValue) async {
  //                     print('current $currentValue');
  //                     final date = await showDialog<DateTime>(
  //                       context: context,
  //                       builder: (BuildContext context) {
  //                         return AlertDialog(
  //                           title: Text('Seleccione un Año'),
  //                           content: Container(
  //                             height: 200,
  //                             width: 200,
  //                             child: YearPicker(
  //                               firstDate: DateTime(1950),
  //                               lastDate: DateTime.now(),
  //                               selectedDate: currentValue ?? DateTime.now(),
  //                               onChanged: (DateTime value) {
  //                                 setState(() {
  //                                   currentValue = value;
  //                                   anioController.text = DateFormat("yyyy").format(value);
  //                                   print('controller ${anioController.text}');
  //                                   Navigator.of(context).pop();
  //                                 });
  //                               },
  //                             ),
  //                           ),
  //                         );
  //                       },
  //                     );

  //                     return date;
  //                   },
  //                 ),
  //                 TextField(
  //                   decoration: InputDecoration(labelText: 'Color'),
  //                   controller: colorController,
  //                 ),
  //                 SizedBox(height: 16),
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceAround,
  //                   children: [
  //                     ElevatedButton(
  //                       onPressed: () {
  //                         context.read<VehiculosBlocDb>().add(
  //                               UpdateVehiculo(
  //                                 vehiculo: Vehiculo(
  //                                   id: vehiculo.id,
  //                                   placa: placaController.text,
  //                                   marca: marcaController.text,
  //                                   modelo: modeloController.text,
  //                                   anio: anioController.text,
  //                                   color: colorController.text,
  //                                 ),
  //                               ),
  //                             );

  //                         Navigator.of(context).pop();
  //                       },
  //                       style: ElevatedButton.styleFrom(
  //                         backgroundColor: Color(0xFF002A52),
  //                       ),
  //                       child: Text(
  //                         'Guardar',
  //                         style: TextStyle(color: Colors.white),
  //                       ),
  //                     ),
  //                     TextButton(
  //                       onPressed: () {
  //                         Navigator.of(context).pop();
  //                       },
  //                       child: Text(
  //                         'Cancelar',
  //                         style: TextStyle(
  //                             fontWeight: FontWeight.bold, color: Colors.white),
  //                       ),
  //                       style: ElevatedButton.styleFrom(
  //                           backgroundColor: Colors.red),
  //                     ),
  //                   ],
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  // void _mostrarDialogoAgregarVehiculo(BuildContext context) {
  //   TextEditingController marcaController = TextEditingController();
  //   TextEditingController placaController = TextEditingController();
  //   TextEditingController modeloController = TextEditingController();
  //   TextEditingController anioController = TextEditingController(text: DateTime.now().year.toString());
  //   TextEditingController colorController = TextEditingController();

  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return Dialog(
  //         child: SingleChildScrollView(
  //           child: Container(
  //             padding: EdgeInsets.all(24),
  //             child: Column(
  //               children: [
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                   children: [
  //                     Text(
  //                       'Nuevo Vehículo',
  //                       style: TextStyle(
  //                         fontSize: 20,
  //                         fontWeight: FontWeight.bold,
  //                         color: Color(0xFF002A52),
  //                       ),
  //                     ),
  //                     IconButton(
  //                       icon: Icon(Icons.close),
  //                       onPressed: () {
  //                         Navigator.of(context).pop();
  //                       },
  //                     ),
  //                   ],
  //                 ),
  //                 SizedBox(height: 16),
  //                 TextField(
  //                   decoration: InputDecoration(labelText: 'Marca'),
  //                   controller: marcaController,
  //                 ),
  //                 TextField(
  //                   decoration: InputDecoration(labelText: 'Placa'),
  //                   controller: placaController,
  //                 ),
  //                 TextField(
  //                   decoration: InputDecoration(labelText: 'Modelo'),
  //                   controller: modeloController,
  //                 ),
  //                 // TextField(
  //                 //   decoration: InputDecoration(labelText: 'Año'),
  //                 //   controller: anioController,
  //                 // ),
  //                 DateTimeField(
  //                   decoration: InputDecoration(labelText: 'Año'),
  //                   controller: anioController,
  //                   format: DateFormat("yyyy"),
  //                   initialValue: DateTime.now(),
  //                   onChanged: (date) {
  //                     print('date: $date');
  //                     setState(() {
  //                       if (date != null) {
  //                         var selectedDate = date;
  //                         anioController.text = DateFormat("yyyy").format(selectedDate);
  //                       }
  //                     });
  //                   },
  //                   onShowPicker: (context, currentValue) async {
  //                     print('current $currentValue');
  //                     final date = await showDialog<DateTime>(
  //                       context: context,
  //                       builder: (BuildContext context) {
  //                         return AlertDialog(
  //                           title: Text('Seleccione un Año'),
  //                           content: Container(
  //                             height: 200,
  //                             width: 200,
  //                             child: YearPicker(
  //                               firstDate: DateTime(1950),
  //                               lastDate: DateTime.now(),
  //                               selectedDate: currentValue ?? DateTime.now(),
  //                               onChanged: (DateTime value) {
  //                                 setState(() {
  //                                   currentValue = value;
  //                                   anioController.text = DateFormat("yyyy").format(value);
  //                                   print('controller ${anioController.text}');
  //                                   Navigator.of(context).pop();
  //                                 });
  //                               },
  //                             ),
  //                           ),
  //                         );
  //                       },
  //                     );

  //                     return date;
  //                   },
  //                 ),
  //                 TextField(
  //                   decoration: InputDecoration(labelText: 'Color'),
  //                   controller: colorController,
  //                 ),
  //                 SizedBox(height: 16),
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceAround,
  //                   children: [
  //                     ElevatedButton(
  //                       onPressed: () {
  //                         context.read<VehiculosBlocDb>().add(
  //                               AddVehiculo(
  //                                 vehiculo: Vehiculo(
  //                                   marca: marcaController.text,
  //                                   placa: placaController.text,
  //                                   modelo: modeloController.text,
  //                                   anio: anioController.text,
  //                                   color: colorController.text,
  //                                 ),
  //                               ),
  //                             );

  //                         Navigator.of(context).pop();
  //                       },
  //                       style: ElevatedButton.styleFrom(
  //                         backgroundColor: Color(0xFF002A52),
  //                       ),
  //                       child: Text(
  //                         'Guardar',
  //                         style: TextStyle(color: Colors.white),
  //                       ),
  //                     ),
  //                     TextButton(
  //                       onPressed: () {
  //                         Navigator.of(context).pop();
  //                       },
  //                       child: Text(
  //                         'Cancelar',
  //                         style: TextStyle(
  //                           color: Colors.white,
  //                           fontWeight: FontWeight.bold,
  //                         ),
  //                       ),
  //                       style: ElevatedButton.styleFrom(
  //                           backgroundColor: Colors.red),
  //                     ),
  //                   ],
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  void _mostrarDialogoEliminarVehiculo(
      BuildContext context, Vehiculo vehiculo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Eliminar Vehículo'),
          content: Text('¿Estás seguro que deseas eliminar este vehículo?'),
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
                context.read<VehiculosBlocDb>().add(
                      DeleteVehiculo(
                        vehiculo: vehiculo,
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
  // void _mostrarDialogoAgregarVehiculo(BuildContext context) {
  //   TextEditingController marcaController = TextEditingController();
  //   TextEditingController modeloController = TextEditingController();
  //   TextEditingController anioController = TextEditingController();
  //   TextEditingController colorController = TextEditingController();

  //   showModalBottomSheet(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return SingleChildScrollView(
  //         child: Container(
  //           padding: EdgeInsets.all(24),
  //           child: Column(
  //             children: [
  //               TextField(
  //                 decoration: InputDecoration(labelText: 'Marca'),
  //                 controller: marcaController,
  //               ),
  //               TextField(
  //                 decoration: InputDecoration(labelText: 'Modelo'),
  //                 controller: modeloController,
  //               ),
  //               TextField(
  //                 decoration: InputDecoration(labelText: 'Año'),
  //                 controller: anioController,
  //               ),
  //               TextField(
  //                 decoration: InputDecoration(labelText: 'Color'),
  //                 controller: colorController,
  //               ),
  //               SizedBox(height: 16),
  //               ElevatedButton(
  //                 onPressed: () {
  //                   context.read<VehiculosBlocDb>().add(
  //                         AddVehiculo(
  //                           vehiculo: Vehiculo(
  //                             marca: marcaController.text,
  //                             modelo: modeloController.text,
  //                             anio: anioController.text,
  //                             color: colorController.text,
  //                           ),
  //                         ),
  //                       );

  //                   Navigator.of(context).pop();
  //                 },
  //                 child: Text('Guardar'),
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  // void _mostrarDialogoEditarVehiculo(BuildContext context, Vehiculo vehiculo) {
  //   TextEditingController idController =
  //       TextEditingController(text: vehiculo.id.toString());
  //   TextEditingController marcaController =
  //       TextEditingController(text: vehiculo.marca);
  //   TextEditingController modeloController =
  //       TextEditingController(text: vehiculo.modelo);
  //   TextEditingController anioController =
  //       TextEditingController(text: vehiculo.anio);
  //   TextEditingController colorController =
  //       TextEditingController(text: vehiculo.color);

  //   showModalBottomSheet(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return SingleChildScrollView(
  //         child: Container(
  //           padding: EdgeInsets.all(24),
  //           child: Column(
  //             children: [
  //               TextField(
  //                 decoration: InputDecoration(labelText: 'ID'),
  //                 controller: idController,
  //                 enabled: false,
  //               ),
  //               TextField(
  //                 decoration: InputDecoration(labelText: 'Marca'),
  //                 controller: marcaController,
  //               ),
  //               TextField(
  //                 decoration: InputDecoration(labelText: 'Modelo'),
  //                 controller: modeloController,
  //               ),
  //               TextField(
  //                 decoration: InputDecoration(labelText: 'Año'),
  //                 controller: anioController,
  //               ),
  //               TextField(
  //                 decoration: InputDecoration(labelText: 'Color'),
  //                 controller: colorController,
  //               ),
  //               SizedBox(height: 16),
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceAround,
  //                 children: [
  //                   ElevatedButton(
  //                     onPressed: () {
  //                       context.read<VehiculosBlocDb>().add(
  //                             UpdateVehiculo(
  //                               vehiculo: Vehiculo(
  //                                 id: vehiculo.id,
  //                                 marca: marcaController.text,
  //                                 modelo: modeloController.text,
  //                                 anio: anioController.text,
  //                                 color: colorController.text,
  //                               ),
  //                             ),
  //                           );

  //                       Navigator.of(context).pop();
  //                     },
  //                     child: Text('Guardar'),
  //                   ),
  //                   TextButton(
  //                     onPressed: () {
  //                       Navigator.of(context).pop();
  //                     },
  //                     child: Text('Cancelar'),
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  void _mostrarSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
