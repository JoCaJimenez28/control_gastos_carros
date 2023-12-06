import 'dart:math';

import 'package:control_gastos_carros/blocs/categoriasBlocDb.dart';
import 'package:control_gastos_carros/blocs/gastosBlocDb.dart';
import 'package:control_gastos_carros/blocs/vehiculosBlocDb.dart';
import 'package:control_gastos_carros/modelos/categorias.dart';
import 'package:control_gastos_carros/modelos/gastos.dart';
import 'package:control_gastos_carros/modelos/vehiculos.dart';
import 'package:datetime_picker_formfield_new/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class InicioScreen extends StatefulWidget {
  @override
  _InicioScreenState createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen>
    with SingleTickerProviderStateMixin {
  DateTime fechaInicio = DateTime(2023, 1, 1);
  DateTime fechaFin = DateTime(2023, 12, 31);
  double totalGastos = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    DateTime now = DateTime.now();
    fechaInicio = DateTime(now.year, now.month, now.day - 7);
    fechaFin = DateTime(now.year, now.month, now.day + 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF002A52),
        title: Text('Control de Gastos', style: TextStyle(color: Colors.white)),
        // bottom: TabBar(
        //   controller: _tabController,
        //   tabs: [
        //     Tab(text: 'Día'),
        //     Tab(text: 'Semana'),
        //     Tab(text: 'Mes'),
        //   ],
        // ),
      ),
      backgroundColor: Color.fromARGB(255, 237, 237, 237),
      body: BlocBuilder<VehiculosBlocDb, VehiculoEstado>(
        builder: (context, vehiculoState) {
          if (vehiculoState.error.isNotEmpty) {
            return Center(
              child: Text(vehiculoState.error),
            );
          }

          if (vehiculoState.vehiculos.isEmpty) {
            return Center(
              child: Text('Agrega un vehiculo!'),
            );
          }

          return BlocBuilder<GastosBloc, GastoEstado>(
            builder: (context, gastoState) {
              if (gastoState.gastos.isEmpty) {
                return Center(
                  child: Text('Agrega gastos a un vehiculo!'),
                );
              }

              return BlocBuilder<CategoriasBloc, CategoriasEstado>(
                builder: (context, categoriasState) {
                  if (categoriasState.error.isNotEmpty) {
                    return Center(
                      child: Text(categoriasState.error),
                    );
                  }

                  if (categoriasState.categorias.isEmpty) {
                    return Center(
                      child: Text('No hay categorías disponibles'),
                    );
                  }
                  return Container(
                    child: _buildFiltroFecha(context, vehiculoState.vehiculos,
                        gastoState.gastos, categoriasState.categorias),
                  );
                  // return TabBarView(
                  //   controller: _tabController,
                  //   children: [
                  //     _buildFiltroFecha('Día', context, vehiculoState.vehiculos,
                  //         gastoState.gastos, categoriasState.categorias),
                  //     _buildFiltroFecha(
                  //         'Semana',
                  //         context,
                  //         vehiculoState.vehiculos,
                  //         gastoState.gastos,
                  //         categoriasState.categorias),
                  //     _buildFiltroFecha('Mes', context, vehiculoState.vehiculos,
                  //         gastoState.gastos, categoriasState.categorias),
                  //   ],
                  // );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFiltroFecha(
      // String filtro,
      BuildContext context,
      List<Vehiculo> vehiculos,
      List<Gasto> gastos,
      List<Categoria> categorias) {
    // Filtrar gastos según las fechas seleccionadas
    List<Gasto> gastosFiltrados = _filtrarGastos(gastos);

    // Calcular el porcentaje de gasto para cada vehículo
    Map<int, double> porcentajes = _calcularPorcentajeGastoPorVehiculo(
      vehiculos,
      gastosFiltrados,
      categorias,
    );

    // Construir la serie de datos para el gráfico
    List<ChartData> data = porcentajes.entries
        .map(
          (entry) => ChartData(
            x: vehiculos.firstWhere((v) => v.id == entry.key).modelo,
            y: double.parse(entry.value.toStringAsFixed(2)),
            color: getRandomColor(),
          ),
        )
        .toList();

    return Column(
      children: [
        Container(
          margin: EdgeInsets.all(8.0),
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: DateTimeField(
                  format: DateFormat("dd-MM-yyyy"),
                  initialValue: fechaInicio,
                  onShowPicker: (context, currentValue) {
                    return showDatePicker(
                      context: context,
                      firstDate: DateTime(2023, 1, 1),
                      initialDate: currentValue ?? DateTime.now(),
                      lastDate: DateTime(2023, 12, 31),
                    );
                  },
                  onChanged: (date) {
                    setState(() {
                      fechaInicio = date ?? fechaInicio;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Fecha de Inicio',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(width: 16), // Añade un espacio entre los DateTimeField
              Expanded(
                child: DateTimeField(
                  format: DateFormat("dd-MM-yyyy"),
                  initialValue: fechaFin,
                  onShowPicker: (context, currentValue) {
                    return showDatePicker(
                      context: context,
                      firstDate: DateTime(2023, 1, 1),
                      initialDate: currentValue ?? fechaFin,
                      lastDate: DateTime(2023, 12, 31),
                    );
                  },
                  onChanged: (date) {
                    setState(() {
                      fechaFin = date?.add(Duration(days: 1)) ?? fechaFin;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Fecha de Fin',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Text('Fechas seleccionadas: $fechaInicio - $fechaFin'),

        Container(
          margin: EdgeInsets.all(8.0),
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: gastosFiltrados.isEmpty
              ? Center(
                  child:
                      Text('No hay gastos dentro de las fechas seleccionadas.'),
                )
              : Column(
                  children: [
                    SfCircularChart(
                      title: ChartTitle(
                          text:
                              '% Gastos semanales por vehiculo: \$$totalGastos'),
                      legend: Legend(isVisible: true),
                      series: <CircularSeries>[
                        PieSeries<ChartData, String>(
                          dataSource: data,
                          xValueMapper: (ChartData data, _) => data.x,
                          yValueMapper: (ChartData data, _) => data.y,
                          pointColorMapper: (ChartData data, _) => data.color,
                          dataLabelSettings: DataLabelSettings(isVisible: true),
                        ),
                      ],
                    ),
                  ],
                ),
        ),

        // Container(
        //   margin: EdgeInsets.all(8.0),
        //   padding: EdgeInsets.all(16.0),
        //   decoration: BoxDecoration(
        //     color: Colors.white,
        //     borderRadius: BorderRadius.circular(8.0),
        //   ),
        //   child: _buildGastosDelDia(gastosFiltrados, vehiculos, categorias),
        // ),
        Expanded(
          child: Container(
            margin: EdgeInsets.all(8.0),
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
            child: _buildGastosDelDia(gastosFiltrados, vehiculos, categorias)
          ),
          // child: ListView.builder(
          //   itemCount: porcentajes.length,
          //   itemBuilder: (context, index) {
          //     var entry = porcentajes.entries.elementAt(index);
          //     var vehiculo = vehiculos.firstWhere((v) => v.id == entry.key);
          //     return ListTile(
          //       title: Text(
          //           '${vehiculo.modelo} - Total: \$${(entry.value * totalGastos / 100).toStringAsFixed(2)} (${entry.value.toStringAsFixed(2)}%)'),
          //     );
          //   },
          // ),
        ),
      ],
    );
  }

  Widget _buildGastosDelDia(List<Gasto> gastos, List<Vehiculo> vehiculos,
      List<Categoria> categorias) {
    DateTime hoy = DateTime.now();
    List<Gasto> gastosDelDia =
        gastos.where((g) => _esMismoDia(g.fecha, hoy)).toList();

    double totalGastosDelDia =
        gastosDelDia.fold(0, (previous, gasto) => previous + gasto.monto);

    if (gastosDelDia.isEmpty) {
      return Center(
        child: Text('No has realizado gastos hoy.'),
      );
    }

    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            alignment: Alignment.center,
            margin: EdgeInsets.all(2.0),
                  padding: EdgeInsets.all(2.0),
                  decoration: BoxDecoration(
                    color: Color(0xCC002A52),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
            child: Text(
              'Gastos del Día: \$${totalGastosDelDia.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          SizedBox(height: 2.0),
          // Text(
          //   'Total del día: \$${totalGastosDelDia.toStringAsFixed(2)}',
          //   style: TextStyle(fontSize: 16.0),
          // ),
          // SizedBox(height: 16.0),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: gastosDelDia.length,
              itemBuilder: (context, index) {
                Gasto gasto = gastosDelDia[index];
            
                Categoria? categoriaDelGasto = categorias
                    .firstWhere((categoria) => categoria.id == gasto.categoriaId);
            
                String nombreCategoria =
                    categoriaDelGasto?.nombre ?? 'Sin categoría';
            
                Vehiculo? vehiculo =
                    vehiculos.firstWhere((v) => v.id == gasto.vehiculoId);
                String modeloVehiculo = vehiculo?.modelo ?? 'Desconocido';
            
                return ListTile(
                  title: Text(
                    '$nombreCategoria \$${gasto.monto}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Vehiculo: ${gasto.vehiculoId != null ? '$modeloVehiculo' : 'Sin vehículo'} \nFecha: ${DateFormat("dd-MM-yyyy").format(gasto.fecha)} \nDescripción: ${gasto.descripcion}',
                  ),
                );
              },
            ),
          ),
        ],
      );
  }

// Función para verificar si dos fechas son del mismo día
  bool _esMismoDia(DateTime fecha1, DateTime fecha2) {
    return fecha1.year == fecha2.year &&
        fecha1.month == fecha2.month &&
        fecha1.day == fecha2.day;
  }

  List<Gasto> _filtrarGastos(List<Gasto> gastos) {
    // Filtro de fechas: Gastos entre fechaInicio y fechaFin, inclusive
    return gastos
        .where(
          (g) =>
              g.fecha.isAfter(fechaInicio.subtract(Duration(days: 1))) &&
              g.fecha.isBefore(fechaFin.add(Duration(days: 1))),
        )
        .toList();
  }

  Map<int, double> _calcularPorcentajeGastoPorVehiculo(
    List<Vehiculo> vehiculos,
    List<Gasto> gastos,
    List<Categoria> categorias,
  ) {
    Map<int, double> porcentajes = {};

    // Calcular el total de gastos
    totalGastos = gastos.fold(
      0,
      (previousValue, gasto) => previousValue + gasto.monto,
    );

    // Calcular el porcentaje de gasto para cada vehículo
    for (var vehiculo in vehiculos) {
      double gastoVehiculo = gastos
          .where((g) => g.vehiculoId == vehiculo.id)
          .fold(0, (previousValue, gasto) => previousValue + gasto.monto);

      double porcentaje = (gastoVehiculo / totalGastos) * 100;
      porcentajes[vehiculo.id!] = porcentaje;
    }

    return porcentajes;
  }

  Color getRandomColor() {
    final random = Random();
    return Color.fromRGBO(
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
      1,
    );
  }
}

class ChartData {
  final String x;
  final double y;
  final Color color;

  ChartData({required this.x, required this.y, required this.color});
}

// class InicioScreen extends StatefulWidget {
//   @override
//   _InicioScreenState createState() => _InicioScreenState();
// }

// class _InicioScreenState extends State<InicioScreen> {
//   DateTime fechaInicio = DateTime(2023, 1, 1);
//   DateTime fechaFin = DateTime(2023, 12, 31);
//   double totalGastos = 0;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Color(0xFF002A52),
//         title: Text('Control de Gastos', style: TextStyle(color: Colors.white)),
//       ),
//       body: BlocBuilder<VehiculosBlocDb, VehiculoEstado>(
//         builder: (context, vehiculoState) {
//           if (vehiculoState.error.isNotEmpty) {
//             return Center(
//               child: Text(vehiculoState.error),
//             );
//           }

//           if (vehiculoState.vehiculos.isEmpty) {
//             return Center(
//               child: Text('No hay vehículos disponibles'),
//             );
//           }

//           return BlocBuilder<GastosBloc, GastoEstado>(
//             builder: (context, gastoState) {
//               if (gastoState.gastos.isEmpty) {
//                 return Center(
//                   child: Text('No hay gastos disponibles'),
//                 );
//               }

//               return BlocBuilder<CategoriasBloc, CategoriasEstado>(
//                 builder: (context, categoriasState) {
//                   if (categoriasState.error.isNotEmpty) {
//                     return Center(
//                       child: Text(categoriasState.error),
//                     );
//                   }

//                   if (categoriasState.categorias.isEmpty) {
//                     return Center(
//                       child: Text('No hay categorías disponibles'),
//                     );
//                   }

//                   List<Gasto> gastosFiltrados =
//                       _filtrarGastos(gastoState.gastos);

//                   Map<int, double> porcentajes =
//                       _calcularPorcentajeGastoPorVehiculo(
//                     vehiculoState.vehiculos,
//                     gastosFiltrados,
//                     categoriasState.categorias,
//                   );

//                   List<ChartData> data = porcentajes.entries
//                       .map(
//                         (entry) => ChartData(
//                           x: vehiculoState.vehiculos
//                               .firstWhere((v) => v.id == entry.key)
//                               .modelo,
//                           y: double.parse(entry.value.toStringAsFixed(2)),
//                           color: getRandomColor(),
//                         ),
//                       )
//                       .toList();

//                   return Container(
//                     margin: EdgeInsets.all(8.0),
//                     padding: EdgeInsets.all(8.0),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(16.0),
//                     ),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           'Porcentaje de gasto por vehículo',
//                           style: TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         SfCircularChart(
//                           title:
//                               ChartTitle(text: 'Gastos totales: $totalGastos'),
//                           legend: Legend(isVisible: true),
//                           series: <CircularSeries>[
//                             PieSeries<ChartData, String>(
//                               dataSource: data,
//                               xValueMapper: (ChartData data, _) => data.x,
//                               yValueMapper: (ChartData data, _) => data.y,
//                               pointColorMapper: (ChartData data, _) =>
//                                   data.color,
//                               dataLabelSettings:
//                                   DataLabelSettings(isVisible: true),
//                             ),
//                           ],
//                         ),
//                         Expanded(
//                           child: ListView.builder(
//                             itemCount: porcentajes.length +
//                                 1, // +1 para agregar el total general
//                             itemBuilder: (context, index) {
//                               if (index == porcentajes.length) {
//                                 // Último elemento, mostrar el total general
//                                 // return ListTile(
//                                 //   title: Text(
//                                 //       // 'Total General - \$${totalGastos.toStringAsFixed(2)}'),
//                                 // );
//                               } else {
//                                 var entry =
//                                     porcentajes.entries.elementAt(index);
//                                 var vehiculo = vehiculoState.vehiculos
//                                     .firstWhere((v) => v.id == entry.key);
//                                 return ListTile(
//                                   title: Text(
//                                       '${vehiculo.modelo} - Total: \$${(entry.value * totalGastos / 100).toStringAsFixed(2)} (${entry.value.toStringAsFixed(2)}%)'),
//                                 );
//                               }
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               );
//             },
//           );
//         },
//       ),
//     );
//   }

//   List<Gasto> _filtrarGastos(List<Gasto> gastos) {
//     // Filtro de fechas: Gastos entre fechaInicio y fechaFin
//     return gastos
//         .where(
//           (g) => g.fecha.isAfter(fechaInicio) && g.fecha.isBefore(fechaFin),
//         )
//         .toList();
//   }

//   Map<int, double> _calcularPorcentajeGastoPorVehiculo(
//     List<Vehiculo> vehiculos,
//     List<Gasto> gastos,
//     List<Categoria> categorias,
//   ) {
//     Map<int, double> porcentajes = {};

//     // Calcular el total de gastos
//     totalGastos = gastos.fold(
//       0,
//       (previousValue, gasto) => previousValue + gasto.monto,
//     );

//     // Calcular el porcentaje de gasto para cada vehículo
//     for (var vehiculo in vehiculos) {
//       double gastoVehiculo = gastos
//           .where((g) => g.vehiculoId == vehiculo.id)
//           .fold(0, (previousValue, gasto) => previousValue + gasto.monto);

//       double porcentaje = (gastoVehiculo / totalGastos) * 100;
//       porcentajes[vehiculo.id!] = porcentaje;
//     }

//     return porcentajes;
//   }

//   Color getRandomColor() {
//     final random = Random();
//     return Color.fromRGBO(
//       random.nextInt(256),
//       random.nextInt(256),
//       random.nextInt(256),
//       1,
//     );
//   }
// }

// class ChartData {
//   final String x;
//   final double y;
//   final Color color;

//   ChartData({required this.x, required this.y, required this.color});
// }

// class InicioScreen extends StatefulWidget {
//   @override
//   _InicioScreenState createState() => _InicioScreenState();
// }

// class _InicioScreenState extends State<InicioScreen> {
//   DateTime fechaInicio = DateTime(
//       2023, 1, 1); // Debes inicializar estas fechas según tus necesidades
//   DateTime fechaFin = DateTime(2023, 12, 31);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Inicio'),
//       ),
//       body: BlocBuilder<VehiculosBlocDb, VehiculoEstado>(
//         builder: (context, vehiculoState) {
//           if (vehiculoState.error.isNotEmpty) {
//             // Manejar el error
//             return Center(
//               child: Text(vehiculoState.error),
//             );
//           }

//           if (vehiculoState.vehiculos.isEmpty) {
//             // Manejar cuando no hay vehículos
//             return Center(
//               child: Text('No hay vehículos disponibles'),
//             );
//           }

//           return BlocBuilder<GastosBloc, GastoEstado>(
//             builder: (context, gastoState) {
//               // if (gastoState.error.isNotEmpty) {
//               //   // Manejar el error
//               //   return Center(
//               //     child: Text(gastoState.error),
//               //   );
//               // }

//               if (gastoState.gastos.isEmpty) {
//                 // Manejar cuando no hay gastos
//                 return Center(
//                   child: Text('No hay gastos disponibles'),
//                 );
//               }

//               return BlocBuilder<CategoriasBloc, CategoriasEstado>(
//                 builder: (context, categoriasState) {
//                   if (categoriasState.error.isNotEmpty) {
//                     // Manejar el error
//                     return Center(
//                       child: Text(categoriasState.error),
//                     );
//                   }

//                   if (categoriasState.categorias.isEmpty) {
//                     // Manejar cuando no hay categorías
//                     return Center(
//                       child: Text('No hay categorías disponibles'),
//                     );
//                   }

//                   // Filtrar gastos según las fechas seleccionadas
//                   List<Gasto> gastosFiltrados =
//                       _filtrarGastos(gastoState.gastos);

//                   // Calcular el porcentaje de gasto para cada vehículo
//                   Map<int, double> porcentajes =
//                       _calcularPorcentajeGastoPorVehiculo(
//                     vehiculoState.vehiculos,
//                     gastosFiltrados,
//                     categoriasState.categorias,
//                   );

//                   // Construir la serie de datos para el gráfico
//                   List<ChartData> data = porcentajes.entries
//                       .map(
//                         (entry) => ChartData(
//                           x: vehiculoState.vehiculos
//                               .firstWhere((v) => v.id == entry.key)
//                               .modelo, // Cambia esto según la estructura de tus vehículos
//                           y: entry.value,
//                           color: getRandomColor(),
//                         ),
//                       )
//                       .toList();

//                   return Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       SfCircularChart(
//                         series: <CircularSeries>[
//                           PieSeries<ChartData, String>(
//                             dataSource: data,
//                             xValueMapper: (ChartData data, _) => data.x,
//                             yValueMapper: (ChartData data, _) => data.y,
//                             pointColorMapper: (ChartData data, _) => data.color,
//                             dataLabelSettings: DataLabelSettings(isVisible: true),
//                           ),
//                         ],
//                       ),
//                     ],
//                   );
//                 },
//               );
//             },
//           );
//         },
//       ),
//     );
//   }

//   // Método para filtrar gastos según las fechas seleccionadas
//   List<Gasto> _filtrarGastos(List<Gasto> gastos) {
//     return gastos
//         .where(
//             (g) => g.fecha.isAfter(fechaInicio) && g.fecha.isBefore(fechaFin))
//         .toList();
//   }

//   // Método para calcular el porcentaje de gasto para cada vehículo
//   Map<int, double> _calcularPorcentajeGastoPorVehiculo(
//     List<Vehiculo> vehiculos,
//     List<Gasto> gastos,
//     List<Categoria> categorias,
//   ) {
//     Map<int, double> porcentajes = {};

//     // Calcular el total de gastos
//     double totalGastos = gastos.fold(
//       0,
//       (previousValue, gasto) => previousValue + gasto.monto,
//     );

//     // Calcular el porcentaje de gasto para cada vehículo
//     for (var vehiculo in vehiculos) {
//       double gastoVehiculo = gastos
//           .where((g) => g.vehiculoId == vehiculo.id)
//           .fold(0, (previousValue, gasto) => previousValue + gasto.monto);

//       double porcentaje = (gastoVehiculo / totalGastos) * 100;
//       porcentajes[vehiculo.id!] = porcentaje;
//     }
//     return porcentajes;
//   }
//     // Método para obtener un color aleatorio para la gráfica
//     Color getRandomColor() {
//       final random = Random();
//       return Color.fromRGBO(
//         random.nextInt(256),
//         random.nextInt(256),
//         random.nextInt(256),
//         1,
//       );
//     }
  
// }

// // Clase de datos para el gráfico
// class ChartData {
//   final String x;
//   final double y;
//   final Color color;

//   ChartData({required this.x, required this.y, required this.color});
// }

// class InicioScreen extends StatefulWidget {
//   @override
//   _InicioScreenState createState() => _InicioScreenState();
// }

// class _InicioScreenState extends State<InicioScreen> {
//   String selectedInterval = 'Día'; // Valor predeterminado

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Inicio'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Text(
//               'Total de Gastos',
//               style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 16.0),
//             Container(
//               height: 300.0,
//               child: LineChart(
//                 _buildGastosChart(),
//               ),
//             ),
//             SizedBox(height: 16.0),
//             _buildIntervalSelector(),
//           ],
//         ),
//       ),
//     );
//   }

//   LineChartData _buildGastosChart() {
//     // Aquí construyes los datos para tu gráfico
//     // Puedes usar la información de tus gastos y el intervalo seleccionado
//     // Consulta la documentación de fl_chart para más detalles: https://pub.dev/packages/fl_chart

//     return LineChartData(
//       // Configuración del gráfico
//       gridData: FlGridData(show: false),
//       titlesData: FlTitlesData(show: false),
//       borderData: FlBorderData(show: true),
//       minX: 0,
//       maxX: 7,
//       minY: 0,
//       maxY: 100,
//       lineBarsData: [
//         LineChartBarData(
//           spots: [
//             FlSpot(0, 20),
//             FlSpot(1, 50),
//             FlSpot(2, 80),
//             FlSpot(3, 40),
//             FlSpot(4, 70),
//             FlSpot(5, 30),
//             FlSpot(6, 60),
//             FlSpot(7, 90),
//           ],
//           isCurved: true,
//           // colors: [Colors.blue],
//           barWidth: 4,
//           isStrokeCapRound: true,
//           belowBarData: BarAreaData(show: false),
//         ),
//       ],
//     );
//   }

//   Widget _buildIntervalSelector() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         _buildIntervalButton('Día'),
//         _buildIntervalButton('Semana'),
//         _buildIntervalButton('Mes'),
//       ],
//     );
//   }

//   Widget _buildIntervalButton(String interval) {
//     return ElevatedButton(
//       onPressed: () {
//         setState(() {
//           selectedInterval = interval;
//         });
//       },
//       style: ElevatedButton.styleFrom(
//         primary: selectedInterval == interval ? Colors.blue : null,
//       ),
//       child: Text(interval),
//     );
//   }
// }