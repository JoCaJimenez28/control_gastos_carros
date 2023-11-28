// import 'package:control_gastos_carros/blocs/gastosBlocPrueba.dart';
import 'package:control_gastos_carros/CategoriasDialog.dart';
import 'package:control_gastos_carros/blocs/categoriasBlocDb.dart';
import 'package:control_gastos_carros/blocs/gastosBlocDb.dart';
import 'package:control_gastos_carros/blocs/vehiculosBlocDb.dart';
import 'package:control_gastos_carros/database/database.dart';
import 'package:control_gastos_carros/gastosScreen.dart';
import 'package:control_gastos_carros/inicioScreen.dart';
import 'package:control_gastos_carros/modelos/categorias.dart';
import 'package:control_gastos_carros/vehiculosScreen.dart';
// import 'package:control_gastos_carros/blocs/vehiculosBlocPrueba.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:control_gastos_carros/modelos/vehiculos.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  DatabaseHelper dbHelper = DatabaseHelper();
  await dbHelper.iniciarDatabase();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    InicioScreen(),
    VehiculosScreen(),
    GastosScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<VehiculosBlocDb>(
          create: (context) => VehiculosBlocDb()..add(VehiculosInicializado()),
        ),
        BlocProvider<CategoriasBloc>(
          create: (context) => CategoriasBloc()..add(Categoriasinicializado()),
        ),
        BlocProvider<GastosBloc>(
          create: (context) => GastosBloc(context)..add(GastosInicializado()),
        ),
      ],
      child: MaterialApp(
        title: 'Control de Gastos de Vehículos',
        debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // primarySwatch: Colors.orange,
        // visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
        home: Scaffold(
          body: _screens[_currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Inicio',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.directions_car),
                label: 'Vehículos',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.attach_money),
                label: 'Gastos',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   DatabaseHelper dbHelper = DatabaseHelper();
//   await dbHelper.iniciarDatabase();

//   runApp(MyApp());
// }

// Widget? currentScreen;

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MultiBlocProvider(
//       providers: [
//         BlocProvider<VehiculosBlocDb>(
//           create: (context) => VehiculosBlocDb()..add(VehiculosInicializado()),
//         ),
//         BlocProvider<CategoriasBloc>(
//           create: (context) => CategoriasBloc()..add(Categoriasinicializado()),
//         ),
//         BlocProvider<GastosBloc>(
//           create: (context) => GastosBloc(context)..add(GastosInicializado()),
//         ),
//       ],
//       child: MaterialApp(
//         title: 'Control de Gastos de Vehículos',
//         home: DefaultTabController(
//           length: 2,
//           child: Scaffold(
//             appBar: AppBar(
//               title: Text('Control de Gastos'),
//               actions: [
//                 PopupMenuButton<String>(
//                   onSelected: (value) {
//                     if (value == 'ver_categorias') {
//                       print('Ver Categorias');
//                       mostrarDialogoVerCategorias(context);
//                     }
//                   },
//                   itemBuilder: (BuildContext context) {
//                     return [
//                       PopupMenuItem<String>(
//                         value: 'ver_categorias',
//                         child: Text('Ver Categorias'),
//                       ),
//                     ];
//                   },
//                 ),
//               ],
//               bottom: TabBar(
//                 tabs: [
//                   Tab(text: 'Vehículos'),
//                   Tab(text: 'Gastos'),
//                 ],
//               ),
//             ),
//             body: TabBarView(
//               children: [
//                 VehiculosScreen(),
//                 GastosScreen(),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

void mostrarDialogoVerCategorias(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        child: BlocBuilder<CategoriasBloc, CategoriasEstado>(
          builder: (context, state) {
            if (state is CategoriasEstado) {
              List<Categoria> categorias = state.categorias;

              return SingleChildScrollView(
                child: Column(
                  children: [
                    for (Categoria categoria in categorias)
                      ListTile(
                        title: Text(categoria.nombre),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            // Handle delete category action
                            context.read<CategoriasBloc>().add(
                                  DeleteCategoria(
                                    categoria: categoria,
                                  ),
                                );
                            Navigator.of(context).pop(); // Close the dialog
                          },
                        ),
                      ),
                  ],
                ),
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      );
    },
  );
}
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => VehiculosBlocDb()..add(VehiculosInicializado()),
//       child: MaterialApp(
//         title: 'Control de Gastos de Vehículos',
//         home: Scaffold(
//           appBar: AppBar(
//             title: Text('Gastos de Vehículos'),
//           ),
//           body: VehiculosScreen(),
//         ),
//       ),
//     );
//   }
// }


// class VehiculosScreen extends StatefulWidget {
//   @override
//   State<VehiculosScreen> createState() => _VehiculosScreenState();
// }

// class _VehiculosScreenState extends State<VehiculosScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Vehículos'),
//       ),
//       body: BlocBuilder<VehiculosBloc, VehiculoEstado>(
//         builder: (context, state) {
//           var estado = context.watch<VehiculosBloc>().state;
//           print('BlocBuilder reconstruido. Nuevo estado: $estado');
//           // if (state is VehiculosInicializado) {
//           //   return Center(
//           //     child: CircularProgressIndicator(),
//           //   );
//           // } else if (state is VehiculosActualizados) {
//               // {print(state.vehiculos);}

//             if (estado.vehiculos.isEmpty) {
//               return Center(
//                 child: Text('No hay vehículos'),
//               );
//             } else {
//               return ListView.builder(
//                   itemCount: estado.vehiculos.length,
//                   itemBuilder: (context, index) {
//                     return ListTile(
//                       title: Text(
//                         'Marca: ${estado.vehiculos[index].marca} - Modelo: ${estado.vehiculos[index].modelo}',
//                       ),
//                       subtitle: Text(
//                         'Año: ${estado.vehiculos[index].anio} - Color: ${estado.vehiculos[index].color}',
//                       ),
//                       trailing: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           IconButton(
//                             icon: Icon(Icons.edit),
//                             color: Colors.blueGrey,
//                             onPressed: () {
//                               _mostrarDialogoEditarVehiculo(
//                                 context,
//                                 estado.vehiculos[index],
//                               );
//                             },
//                           ),
//                           IconButton(
//                             icon: Icon(Icons.delete),
//                             color: Colors.red,
//                             onPressed: /* pressedEliminar(context, estado.vehiculos[index]) */
//                             () {
//                               context.read<VehiculosBloc>().add(
//                                     DeleteVehiculo(
//                                       vehiculo: estado.vehiculos[index],
//                                     ),
//                                   );
//                             }, 
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 );
              
//             }
//           // } else {
//           //   return Center(
//           //     child: Text('Error en el estado del Bloc'),
//           //   );
//           // }
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           _mostrarDialogoAgregarVehiculo(context);
//         },
//         child: Icon(Icons.add),
//       ),
//     );
//   }

//   VoidCallback? pressedEliminar(BuildContext context, Vehiculo vehiculo){
//     var estado = context.watch<VehiculosBloc>().state;

//   switch(estado.runtimeType){
//     case VehiculosInicial:
//       return null;
//       break;
//     default:
//     if((estado as VehiculosActualizados).vehiculos.isEmpty) return null;
//       return(){
//         context.read<VehiculosBloc>().add(DeleteVehiculo(vehiculo: vehiculo));
//       };
//   }
// }

//   void _mostrarDialogoEditarVehiculo(BuildContext context, Vehiculo vehiculo) {
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
//                       context.watch<VehiculosBloc>().add(
//                             UpdateVehiculo(
//                               vehiculo: Vehiculo(
//                                 id: int.parse(idController.text),
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

// void _mostrarDialogoAgregarVehiculo(BuildContext context) {
//   TextEditingController idController = TextEditingController();
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
//                 decoration: InputDecoration(labelText: 'ID'),
//                 controller: idController,
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
//               ElevatedButton(
//                 onPressed: () {
//                   context.read<VehiculosBloc>().add(
//                         AddVehiculo(
//                           vehiculo: Vehiculo(
//                             id: int.parse(idController.text),
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
// }

