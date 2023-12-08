// import 'package:control_gastos_carros/CategoriasDialog.dart';
import 'package:control_gastos_carros/blocs/categoriasBlocDb.dart';
import 'package:control_gastos_carros/blocs/gastosBlocDb.dart';
import 'package:control_gastos_carros/blocs/vehiculosBlocDb.dart';
import 'package:control_gastos_carros/database/database.dart';
import 'package:control_gastos_carros/gastosScreen.dart';
import 'package:control_gastos_carros/inicioScreen.dart';
import 'package:control_gastos_carros/modelos/categorias.dart';
import 'package:control_gastos_carros/vehiculosScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  DatabaseHelper dbHelper = DatabaseHelper();
  await dbHelper.iniciarDatabase();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]);
  
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
          create: (context) => VehiculosBlocDb(context)..add(VehiculosInicializado()),
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
        // theme: ThemeData(
        //   primarySwatch: MaterialColor(0xFF002A52, <int, Color>{
        //     50: Color(0xFF002A52),
        //     100: Color(0xFF002A52),
        //     200: Color(0xFF002A52),
        //     300: Color(0xFF002A52),
        //     400: Color(0xFF002A52),
        //     500: Color(0xFF002A52),
        //     600: Color(0xFF002A52),
        //     700: Color(0xFF002A52),
        //     800: Color(0xFF002A52),
        //     900: Color(0xFF002A52),
        //   }),
        //   primaryColor: Color(0xFF002A52),
        //   /* accentColor: Colors.amber,
        //   accentColorBrightness: Brightness.dark */
        //   visualDensity: VisualDensity.adaptivePlatformDensity,
        // ),
        home: Scaffold(
          body: _screens[_currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            selectedItemColor: Color(0xFF002A52),
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: const [
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

void mostrarDialogoVerCategorias(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        child: BlocBuilder<CategoriasBloc, CategoriasEstado>(
          builder: (context, state) {
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
                    },
        ),
      );
    },
  );
}

