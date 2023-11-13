import 'package:control_gastos_carros/blocs/vehiculosBloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:control_gastos_carros/modelos/vehiculos.dart';

void main() {
  // Crear un vehículo de ejemplo
  // Vehiculo vehiculoEjemplo = Vehiculo(
  //   id: 1,
  //   marca: 'Ejemplo',
  //   modelo: 'Modelo Ejemplo',
  //   anio: '2022',
  //   color: 'Rojo',
  // );

  // // Crear el Bloc y agregar el vehículo de ejemplo
  // VehiculosBloc vehiculosBloc = VehiculosBloc();
  // vehiculosBloc.add(AddVehiculo(vehiculo: vehiculoEjemplo));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Control de Gastos de Vehículos',
      home: BlocProvider(
        create: (context) => VehiculosBloc(),
        child: VehiculosScreen(),
      ),
    );
  }
}

class VehiculosScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vehículos'),
      ),
      body: BlocBuilder<VehiculosBloc, VehiculoEstado>(
        builder: (context, state) {
          if (state is VehiculosInicial) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is VehiculosActualizados) {
            if (state.vehiculos.isEmpty) {
              return Center(
                child: Text('No hay vehículos'),
              );
            } else {
              return ListView.builder(
                itemCount: state.vehiculos.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      'Marca: ${state.vehiculos[index].marca} - Modelo: ${state.vehiculos[index].modelo}',
                    ),
                    subtitle: Text(
                      'Año: ${state.vehiculos[index].anio} - Color: ${state.vehiculos[index].color}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            _mostrarDialogoEditarVehiculo(
                              context,
                              state.vehiculos[index],
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            context.read<VehiculosBloc>().add(
                                  DeleteVehiculo(
                                    vehiculo: state.vehiculos[index],
                                  ),
                                );
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            }
          } else {
            return Center(
              child: Text('Error en el estado del Bloc'),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _mostrarDialogoAgregarVehiculo(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _mostrarDialogoEditarVehiculo(BuildContext context, Vehiculo vehiculo) {
    TextEditingController idController =
        TextEditingController(text: vehiculo.id.toString());
    TextEditingController marcaController =
        TextEditingController(text: vehiculo.marca);
    TextEditingController modeloController =
        TextEditingController(text: vehiculo.modelo);
    TextEditingController anioController =
        TextEditingController(text: vehiculo.anio);
    TextEditingController colorController =
        TextEditingController(text: vehiculo.color);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Editar Vehículo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'ID'),
                controller: idController,
                enabled: false,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Marca'),
                controller: marcaController,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Modelo'),
                controller: modeloController,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Año'),
                controller: anioController,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Color'),
                controller: colorController,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                context.read<VehiculosBloc>().add(
                      UpdateVehiculo(
                        vehiculo: Vehiculo(
                          id: int.parse(idController.text),
                          marca: marcaController.text,
                          modelo: modeloController.text,
                          anio: anioController.text,
                          color: colorController.text,
                        ),
                      ),
                    );

                Navigator.of(context).pop();
              },
              child: Text('Guardar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarDialogoAgregarVehiculo(BuildContext context) {
    TextEditingController marcaController = TextEditingController();
    TextEditingController modeloController = TextEditingController();
    TextEditingController anioController = TextEditingController();
    TextEditingController colorController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Agregar Vehículo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Marca'),
                controller: marcaController,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Modelo'),
                controller: modeloController,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Año'),
                controller: anioController,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Color'),
                controller: colorController,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                context.read<VehiculosBloc>().add(
                      AddVehiculo(
                        vehiculo: Vehiculo(
                          id: 1,
                          marca: marcaController.text,
                          modelo: modeloController.text,
                          anio: anioController.text,
                          color: colorController.text,
                        ),
                      ),
                    );

                Navigator.of(context).pop();
              },
              child: Text('Guardar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }
}