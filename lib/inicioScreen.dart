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

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    fechaInicio = DateTime(now.year, now.month, now.day - 7);
    fechaFin = DateTime(now.year, now.month, now.day + 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF002A52),
        title: const Text('Control de Gastos', style: TextStyle(color: Colors.white)),
        // bottom: TabBar(
        //   controller: _tabController,
        //   tabs: [
        //     Tab(text: 'Día'),
        //     Tab(text: 'Semana'),
        //     Tab(text: 'Mes'),
        //   ],
        // ),
      ),
      backgroundColor: const Color.fromARGB(255, 237, 237, 237),
      body: BlocBuilder<VehiculosBlocDb, VehiculoEstado>(
        builder: (context, vehiculoState) {
          if (vehiculoState.error.isNotEmpty) {
            return Center(
              child: Text(vehiculoState.error),
            );
          }

          if (vehiculoState.vehiculos.isEmpty) {
            return const Center(
              child: Text('Agrega un vehiculo!'),
            );
          }

          return BlocBuilder<GastosBloc, GastoEstado>(
            builder: (context, gastoState) {
              if (gastoState.gastos.isEmpty) {
                return const Center(
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
                    return const Center(
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

  Widget _buildFiltroFecha(BuildContext context, List<Vehiculo> vehiculos, List<Gasto> gastos, List<Categoria> categorias) {

    List<Gasto> gastosFiltrados = _filtrarGastos(gastos);

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
          margin: const EdgeInsets.all(8.0),
          padding: const EdgeInsets.all(16.0),
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
                  decoration: const InputDecoration(
                    labelText: 'Fecha de Inicio',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 16), 
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
                      fechaFin = date?.add(const Duration(days: 1)) ?? fechaFin;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Fecha de Fin',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
        ),
        

        Container(
          margin: const EdgeInsets.all(8.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: gastosFiltrados.isEmpty
              ? const Center(
                  child:
                      Text('No hay gastos dentro de las fechas seleccionadas.'),
                )
              : Column(
                  children: [
                    SfCircularChart(
                      title: ChartTitle(
                          text:
                              '% Gastos semanales por vehiculo: \$$totalGastos'),
                      legend: const Legend(isVisible: true),
                      series: <CircularSeries>[
                        PieSeries<ChartData, String>(
                          dataSource: data,
                          xValueMapper: (ChartData data, _) => data.x,
                          yValueMapper: (ChartData data, _) => data.y,
                          pointColorMapper: (ChartData data, _) => data.color,
                          dataLabelSettings: const DataLabelSettings(isVisible: true),
                        ),
                      ],
                    ),
                  ],
                ),
        ),

        Expanded(
          child: Container(
            margin: const EdgeInsets.all(8.0),
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
            child: _buildGastosDelDia(gastosFiltrados, vehiculos, categorias)
          ),
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
      return const Center(
        child: Text('No has realizado gastos hoy.'),
      );
    }

    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.all(2.0),
                  padding: const EdgeInsets.all(2.0),
                  decoration: BoxDecoration(
                    color: const Color(0xCC002A52),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
            child: Text(
              'Gastos del Día: \$${totalGastosDelDia.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          const SizedBox(height: 2.0),
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
                String modeloVehiculo = vehiculo.modelo ?? 'Desconocido';
            
                return ListTile(
                  title: Text(
                    '$nombreCategoria \$${gasto.monto}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Vehiculo: ${gasto.vehiculoId != null ? modeloVehiculo : 'Sin vehículo'} \nFecha: ${DateFormat("dd-MM-yyyy").format(gasto.fecha)} \nDescripción: ${gasto.descripcion}',
                  ),
                );
              },
            ),
          ),
        ],
      );
  }

  bool _esMismoDia(DateTime fecha1, DateTime fecha2) {
    return fecha1.year == fecha2.year &&
        fecha1.month == fecha2.month &&
        fecha1.day == fecha2.day;
  }

  List<Gasto> _filtrarGastos(List<Gasto> gastos) {
    return gastos
        .where(
          (g) =>
              g.fecha.isAfter(fechaInicio.subtract(const Duration(days: 1))) &&
              g.fecha.isBefore(fechaFin.add(const Duration(days: 1))),
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