import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:control_gastos_carros/blocs/vehiculosBlocDb.dart';
import 'package:control_gastos_carros/database/database.dart';
import 'package:control_gastos_carros/modelos/gastos.dart';
import 'package:control_gastos_carros/modelos/vehiculos.dart';
import 'package:equatable/equatable.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

late DatabaseHelper db;
//Eventos
sealed class GastoEvento {}

class GastosInicializado extends GastoEvento {}

class AddGasto extends GastoEvento {
  final Gasto gasto;
  final BuildContext context;

  AddGasto({required this.gasto, required this.context});
}

class UpdateGasto extends GastoEvento {
  final Gasto gasto;

  UpdateGasto({required this.gasto});
}

class DeleteGasto extends GastoEvento {
  final Gasto gasto;

  DeleteGasto({required this.gasto});
}

//Estados
class GastoEstado with EquatableMixin {
  final List<Gasto> gastos;

  GastoEstado._() : gastos = [];

  GastoEstado({required this.gastos});

  @override
  List<Object?> get props => [gastos];
}

//Bloc
class GastosBloc extends Bloc<GastoEvento, GastoEstado> {
  final BuildContext context;
  List<Gasto> _gastos = [];

  GastosBloc(this.context) : super(GastoEstado._()) {
    on<GastosInicializado>((event, emit) async {
      await DatabaseHelper().iniciarDatabase();
      _gastos = await getAllGastosFromDb();
      emit(GastoEstado(gastos: _gastos));
    });
    on<AddGasto>(_addGasto);
    on<UpdateGasto>(_updateGasto);
    on<DeleteGasto>(_deleteGasto);
  }

  void _addGasto(AddGasto event, Emitter<GastoEstado> emit) async {
    Vehiculo? vehiculo = await this.context.read<VehiculosBlocDb>().getVehiculoById(event.gasto.vehiculoId);

    if (vehiculo != null) {
      try {
        await DatabaseHelper().iniciarDatabase();
        _gastos = await insertGasto(event.gasto);
        emit(GastoEstado(gastos: _gastos));
      } catch (e) {
        // emitErrorSnackBar(emit, 'Error al agregar gasto: $e');
        print('error al agregar gasto');
      }
    } else {
      print('No existe el vehiculo');
    }
  }

  void _updateGasto(UpdateGasto event, Emitter<GastoEstado> emit) {
    List<Gasto> updatedGastos = List.from(state.gastos);
    int index = updatedGastos
        .indexWhere((gasto) => gasto.id == event.gasto.id);
    print('lista sin actualizar: $updatedGastos ');

    if (index != -1) {
      updatedGastos[index] = event.gasto;
      print('Gasto actualizado: $updatedGastos ');
      emit(GastoEstado(gastos: updatedGastos));
      print('estado ${state.gastos}');
    } else {
      print('Vehículo no encontrado para actualizar');
    }
  }

  void _deleteGasto(DeleteGasto event, Emitter<GastoEstado> emit) {
    List<Gasto> updatedGastos = List.from(state.gastos);
    if (_gastos.contains(event.gasto)) {
      // _gastos = _gastos.copiar()..remove(event.gasto);
      print('a eliminar; ${event.gasto}');
      emit(GastoEstado(gastos: _gastos));
      print('estado; ${state.gastos}');
    } else {
      print("no se encontro el vehiculo a eliminar");
    }
  }
}

Future<List<Gasto>> getAllGastosFromDb() async {
    final Database? db = await DatabaseHelper().database;

    if (db == null) {
      print('Error: Database not initialized.');
      return [];
    }

    List<Map<String, dynamic>> data = await db.query('gastos');
    List<Gasto> listaOriginal = data.map((e) {
     return Gasto(
          id: e['ID'],
          tipoGasto: e['tipoGasto'],
          monto: double.parse(e['monto'].toString()),
          fecha: DateTime.parse(e['fecha']),
          descripcion: e['descripcion'],
          vehiculoId: e['vehiculoId']);
    }).toList();

    return listaOriginal;
  }

  Future<List<Gasto>> insertGasto(Gasto gasto) async {
    final Database? db = await DatabaseHelper().database;

    if (db == null) {
      print('Error: Database not initialized.');
      return [];
    }

    await db.insert(
      'gastos',
      {
        'tipoGasto': gasto.tipoGasto,
        'monto': gasto.monto,
        'fecha': gasto.fecha.toIso8601String(),
        'descripcion': gasto.descripcion,
        'vehiculoId': gasto.vehiculoId
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    List<Map<String, dynamic>> data = await db.query('gastos');
    List<Gasto> listaOriginal = data.map((e) {
      return Gasto(
          id: e['ID'],
          tipoGasto: e['tipoGasto'],
          monto: double.parse(e['monto'].toString()),
          fecha: DateTime.parse(e['fecha']),
          descripcion: e['descripcion'],
          vehiculoId: e['vehiculoId']);
    }).toList();

    return listaOriginal;
  }

  Future<Vehiculo?> getVehiculoById(int id) async {
    final Database? db = await DatabaseHelper().database;

    if (db == null) {
      print('Error: Database not initialized.');
      return null;
    }

    List<Map<String, dynamic>> data = await db.query(
      'vehiculos',
      where:
          'ID = ?',
      whereArgs: [id],
    );

    if (data.isNotEmpty) {
      Map<String, dynamic> vehiculoData = data.first;
      return Vehiculo(
        id: vehiculoData['ID'],
        marca: vehiculoData['marca'],
        modelo: vehiculoData['modelo'],
        anio: vehiculoData['anio'],
        color: vehiculoData['color'],
      );
    } else {
      print('Vehículo con id $id no encontrado.');
      return null;
    }
  }

  Future<Vehiculo?> getVehiculoByModelo(String modelo) async {
    final Database? db = await DatabaseHelper().database;

    if (db == null) {
      print('Error: Database not initialized.');
      return null;
    }

    List<Map<String, dynamic>> data = await db.query(
      'vehiculos',
      where:
          'modelo = ?', 
      whereArgs: [modelo],
    );

    if (data.isNotEmpty) {
      Map<String, dynamic> vehiculoData = data.first;
      return Vehiculo(
        id: vehiculoData['ID'],
        marca: vehiculoData['marca'],
        modelo: vehiculoData['modelo'],
        anio: vehiculoData['anio'],
        color: vehiculoData['color'],
      );
    } else {
      print('Vehículo con modelo $modelo no encontrado.');
      return null;
    }
  }

  Future<List<Vehiculo>> updateVehiculo(Vehiculo? vehiculo) async {
    final Database? db = await DatabaseHelper().database;
    print("entro al update");
    if (vehiculo == null) {
      print("no hay vehiculo");
      return [];
    }

    if (db == null) {
      print('Error: Database not initialized.');
      return [];
    }

    await db.update(
      'vehiculos',
      {
        'marca': vehiculo.marca,
        'modelo': vehiculo.modelo,
        'anio': vehiculo.anio,
        'color': vehiculo.color
      },
      where: 'ID = ?', 
      whereArgs: [vehiculo.id], 
    );

    List<Map<String, dynamic>> data = await db.query('vehiculos');
    List<Vehiculo> listaOriginal = data.map((e) {
      return Vehiculo(
        id: e['ID'],
        marca: e['marca'],
        modelo: e['modelo'],
        anio: e['anio'],
        color: e['color'],
      );
    }).toList();

    return listaOriginal;
  }

  Future<List<Vehiculo>> deleteVehiculo(Vehiculo vehiculo) async {
    final Database? db = await DatabaseHelper().database;

    if (db == null) {
      print('Error: Database not initialized.');
      return [];
    }

    await db.delete(
      'vehiculos',
      where: 'ID = ?',
      whereArgs: [vehiculo.id], 
    );

    List<Map<String, dynamic>> data = await db.query('vehiculos');
    List<Vehiculo> updatedList = data.map((e) {
      return Vehiculo(
        id: e['ID'],
        marca: e['marca'],
        modelo: e['modelo'],
        anio: e['anio'],
        color: e['color'],
      );
    }).toList();

    return updatedList;
  }


Future<List<Vehiculo>> obtenerVehiculos() async {
  final Database? db = await DatabaseHelper().database;
  if (db == null) {
    print('Error: Database not initialized.');
    return [];
  }
  try {
    final List<Map<String, dynamic>> maps = await db.query('vehiculos');

    return List.generate(maps.length, (index) {
      return Vehiculo(
        id: maps[index]['ID'],
        marca: maps[index]['marca'],
        modelo: maps[index]['modelo'],
        anio: maps[index]['anio'],
        color: maps[index]['color'],
      );
    });
  } catch (e) {
    print('Error al obtener vehículos: $e');
    throw Exception('Error al obtener vehículos: $e');
  }
}