import 'package:flutter/material.dart';

// import 'package:fl_chart/fl_chart.dart';

class InicioScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pantalla de inicio'),
      ),
      body: Center(
        child: Text('Inicio'),
      ),
    );
  }
}

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