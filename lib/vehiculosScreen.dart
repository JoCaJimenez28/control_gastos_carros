// import 'package:control_gastos_carros/blocs/gastosBlocPrueba.dart';
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

  @override
  void initState() {
    super.initState();
    // context.read<GastosBloc>().add(GastosInicializado());
  }
  final RegExp caracteresEspeciales = RegExp(r'[!@#%^&*(),.?":{}|<>0-9]');

  @override
  Widget build(BuildContext context) {
    var estado = context.watch<VehiculosBlocDb>().state;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF002A52),
        title: const Text('Vehículos', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.search,
              color: Colors.white,
            ),
            onPressed: () async {
              final result = await showSearch(
                context: context,
                delegate: VehiculosSearch(vehiculos: estado.vehiculos),
              );
              // Puedes realizar acciones con el resultado si es necesario
              print('Resultado de la búsqueda: $result');
            },
          ),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 237, 237, 237),
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
                      'Total de Autos',
                      style: TextStyle(color: Colors.white, fontSize: 18.0),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      '${estado.vehiculos.length}',
                      style: const TextStyle(
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
                  margin: const EdgeInsets.all(8.0),
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: estado.vehiculos.isEmpty
                      ? const Center(
                          child: Text('No hay vehículos'),
                        )
                      : ListView.builder(
                          itemCount: estado.vehiculos.length,
                          itemBuilder: (context, index) {
                            List<Vehiculo> vehiculosOrdenados =
                                List.from(estado.vehiculos);
                            vehiculosOrdenados
                                .sort((a, b) => a.modelo.compareTo(b.modelo));

                            return ListTile(
                              // tileColor: const Color(0xFFCFE7FF),
                              title: Text(
                                '${vehiculosOrdenados[index].modelo} - ${vehiculosOrdenados[index].marca}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                'Placa: ${vehiculosOrdenados[index].placa} \nAño: ${vehiculosOrdenados[index].anio} \nMarca: ${vehiculosOrdenados[index].marca} \nColor: ${vehiculosOrdenados[index].color}',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    color: Colors.blueGrey,
                                    onPressed: () {
                                      _mostrarDialogoEditarVehiculo(
                                        context,
                                        vehiculosOrdenados[index],
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    color: Colors.red,
                                    onPressed: () {
                                      _mostrarDialogoEliminarVehiculo(context, vehiculosOrdenados[index]
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
        backgroundColor: const Color(0xFF002A52),
        onPressed: () {
          _mostrarDialogoAgregarVehiculo(context);
        },
        child: const Icon(
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
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Nuevo Vehículo',
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
                      decoration: const InputDecoration(labelText: 'Marca'),
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
                      decoration: const InputDecoration(labelText: 'Placa (ej. AAA-0000)'),
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

                        if (placaExiste) return 'Esta placa ya está registrada';
                        return null;
                      },
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Modelo'),
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
                      decoration: const InputDecoration(labelText: 'Año'),
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
                              title: const Text('Seleccione un Año'),
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
                      decoration: const InputDecoration(labelText: 'Color'),
                      controller: colorController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Este campo no puede estar vacío';
                        }
                        return null;
                      },
                      // validator: (value) {
                      //   if (value == null || value.isEmpty) {
                      //     return 'Este campo no puede estar vacío';
                      //   }

                      //   // Verificar que no contiene caracteres especiales o números
                      //   if (caracteresEspeciales.hasMatch(value)) {
                      //     return 'No se permiten caracteres especiales ni números';
                      //   }
                      //   return null;
                      // },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              try {
                                context.read<VehiculosBlocDb>().add(
                                      AddVehiculo(
                                        vehiculo: Vehiculo(
                                          placa: placaController.text
                                              .toUpperCase(),
                                          marca: marcaController.text,
                                          modelo: modeloController.text,
                                          anio: anioController.text,
                                          color: colorController.text,
                                        ),
                                      ),
                                    );
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text(
                                    "Vehículo agregado!",
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
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                Navigator.of(context).pop();
                              }
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
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Editar Vehículo',
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
                      decoration: const InputDecoration(labelText: 'ID'),
                      controller:
                          TextEditingController(text: vehiculo.id.toString()),
                      enabled: false,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Marca'),
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
                      decoration: const InputDecoration(labelText: 'Placa (ej. AAA-0000)'),
                      controller: placaController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Este campo no puede estar vacío';
                        }
                        // Validación de formato de placa
                        final formatoPlaca = RegExp(r'^[A-Z]{3}-\d{4}$');
                        if (!formatoPlaca.hasMatch(value.toUpperCase())) {
                          return 'Formato de placa inválido';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Modelo'),
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
                      decoration: const InputDecoration(labelText: 'Año'),
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
                              title: const Text('Seleccione un Año'),
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
                      decoration: const InputDecoration(labelText: 'Color'),
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
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              try {
                                context.read<VehiculosBlocDb>().add(
                                      UpdateVehiculo(
                                        vehiculo: Vehiculo(
                                          id: vehiculo.id,
                                          placa: placaController.text
                                              .toUpperCase(),
                                          marca: marcaController.text,
                                          modelo: modeloController.text,
                                          anio: anioController.text,
                                          color: colorController.text,
                                        ),
                                      ),
                                    );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Vehículo actualizado!",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                Navigator.of(context).pop();
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      e.toString(),
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                Navigator.of(context).pop();
                              }
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
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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

  void _mostrarDialogoEliminarVehiculo(
    BuildContext context, Vehiculo vehiculo) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('¿Eliminar éste vehículo?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        content: const Text('Esta acción borrará el vehículo y sus gastos permanentemente'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cancelar
            },
            child: const Text('Cancelar',
                style: TextStyle(
                  color: Color(0xFF002A52),
                  fontWeight: FontWeight.bold,
                )),
          ),
          ElevatedButton(
            onPressed: () {              
              context.read<VehiculosBlocDb>().add(
                    DeleteVehiculo(context: context, vehiculo: vehiculo),
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

  void _mostrarSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class VehiculosSearch extends SearchDelegate<String> {
  final List<Vehiculo> vehiculos;

  VehiculosSearch({required this.vehiculos});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = vehiculos.where(
      (vehiculo) => vehiculo.modelo.toLowerCase().contains(query.toLowerCase()),
    );
    List<Vehiculo> resultsList = results.toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(resultsList[index].modelo),
          subtitle: Text(resultsList[index].placa),
          onTap: () {
            close(context, resultsList[index].modelo);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = vehiculos.where(
      (vehiculo) => vehiculo.modelo.toLowerCase().contains(query.toLowerCase()),
    );
    List<Vehiculo> suggestionsList = suggestions.toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(suggestionsList[index].modelo),
          subtitle: Text(suggestionsList[index].placa),
          onTap: () {
            // close(context, suggestionsList[index].modelo);
          },
        );
      },
    );
  }
}
