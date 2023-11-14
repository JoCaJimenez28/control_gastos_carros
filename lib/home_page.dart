// import 'package:control_gastos_carros/blocs/vehiculosBloc.dart';
// import 'package:control_gastos_carros/modelos/vehiculos.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// @override
// Widget build(BuildContext context) => Scaffold(
//   appBar: AppBar(title: const Text("Vehiculos")),
//   body: BlocBuilder<VehiculosBloc,VehiculoEstado>(
//     builder: (context, state){
//       if(state is VehiculosActualizados && state.vehiculos.isNotEmpty){
//         final vehiculos = state.vehiculos;
//         return ListView.builder(
//           itemCount: vehiculos.length,
//           itemBuilder: (context, index){
//             final vehiculo = vehiculos[index];
//             return buildElementoVehiculo(context, vehiculo);
//           },
//         );
//       } else {
//         return const SizedBox(
//           width: double.infinity,
//           child: Center(child: Text('No se encontraron vehiculos'),),
//         )
//       }
//     },
//   )
// );

// Widget buildElementoVehiculo(BuildContext context, Vehiculo vehiculo){
//   return ListTile(
//     title: Text(vehiculo.modelo + " " + vehiculo.anio),
//     subtitle: Text(vehiculo.marca),
//     trailing: Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         IconButton(
//           onPressed: () {
//             VehiculosBloc(context).add(DeleteVehiculo(vehiculo: vehiculo));
//           },
//           icon: const Icon(Icons.delete, size: 30, color: Colors.red,),
//         ),
//         IconButton(
//           onPressed: () {
//             marca.text = vehiculo.marca;
//             modelo.text = vehiculo.modelo;
//             color.text = vehiculo.color;
//             anio.text = vehiculo.anio;
//             showBottomSheet(context: context, id: vehiculo.id, isEdit: true);
//           },
//           icon: icon
//         )
//       ],
//     ),
//   );
// }

// void showBottomSheet({
//   required BuildContext context,
//   bool isEdit = false,
//   required int id,
// }) => showModalBottomSheet(
//   context: context,
//   isScrollControlled: true,
//   builder: (context) {
//     return Padding(
//       padding: EdgeInsets.only(
//         bottom: MediaQuery.of(context).viewInsets.bottom
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           buildTextField(controller: marca, hint: 'Ingresa la marca'),
//           buildTextField(controller: modelo, hint: 'Ingresa el modelo'),
//           buildTextField(controller: color, hint: 'Ingresa el color'),
//           buildTextField(controller: anio, hint: 'Ingresa el año'),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: ElevatedButton(
//               onPressed: () {
//                 final vehiculo = Vehiculo(id: id, marca: marca.text, modelo: modelo.text, anio: anio.text, color: color.text);
//                 if(isEdit)
//               },
//             ),
//           )
//         ],
//       ),
//     )
//   }
// )



// BlocBuilder<VehiculosBloc, VehiculoEstado>(
//         builder: (context, state) {
//           print('BlocBuilder reconstruido. Nuevo estado: $state');
//           if (state is VehiculosInicializado) {
//             return Center(
//               child: CircularProgressIndicator(),
//             );
//           } else if (state is VehiculosActualizados) {
//               // {print(state.vehiculos);}

//             if (state.vehiculos.isEmpty) {
//               return Center(
//                 child: Text('No hay vehículos'),
//               );
//             } else {
//               return ListView.builder(
//                   itemCount: state.vehiculos.length,
//                   itemBuilder: (context, index) {
//                     return ListTile(
//                       title: Text(
//                         'Marca: ${state.vehiculos[index].marca} - Modelo: ${state.vehiculos[index].modelo}',
//                       ),
//                       subtitle: Text(
//                         'Año: ${state.vehiculos[index].anio} - Color: ${state.vehiculos[index].color}',
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
//                                 state.vehiculos[index],
//                               );
//                             },
//                           ),
//                           IconButton(
//                             icon: Icon(Icons.delete),
//                             color: Colors.red,
//                             onPressed: () {
//                               context.read<VehiculosBloc>().add(
//                                     DeleteVehiculo(
//                                       vehiculo: state.vehiculos[index],
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
//           } else {
//             return Center(
//               child: Text('Error en el estado del Bloc'),
//             );
//           }
//         },
//       ),



//       class lista extends StatelessWidget {
//   const lista({super.key});

//   @override
//   Widget build(BuildContext context) {
    
//     var estado = context.watch<VehiculosBloc>().state;
//     List<Vehiculo> vehiculos = (estado as VehiculosActualizados).vehiculos;

//     if(estado is VehiculosInicial || vehiculos.isEmpty){
//       return Text('no hay carros pa');
//     }

//     return ListView.builder(
//       itemCount: vehiculos.length,
//       itemBuilder: (context, index) {
//                     return ListTile(
//                       title: Text(
//                         'Marca: ${vehiculos[index].marca} - Modelo: ${vehiculos[index].modelo}',
//                       ),
//                       subtitle: Text(
//                         'Año: ${vehiculos[index].anio} - Color: ${vehiculos[index].color}',
//                       ),
//                       trailing: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           IconButton(
//                             icon: Icon(Icons.edit),
//                             color: Colors.blueGrey,
//                             onPressed: () {
//                               // _mostrarDialogoEditarVehiculo(
//                               //   context,
//                               //   vehiculos[index],
//                               // );
//                             },
//                           ),
//                           IconButton(
//                             icon: Icon(Icons.delete),
//                             color: Colors.red,
//                             onPressed: () {
//                               context.read<VehiculosBloc>().add(
//                                     DeleteVehiculo(
//                                       vehiculo: vehiculos[index],
//                                     ),
//                                   );
//                             },
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//       );
//   }
// }