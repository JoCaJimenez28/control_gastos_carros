import 'package:bloc/bloc.dart';
import 'package:control_gastos_carros/modelos/categorias.dart';
import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';
import 'package:control_gastos_carros/database/database.dart';
import 'package:control_gastos_carros/modelos/vehiculos.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

late DatabaseHelper db;

sealed class CategoriaEvento {}

class Categoriasinicializado extends CategoriaEvento {}

class AddCategoria extends CategoriaEvento {
  final Categoria categoria;

  AddCategoria({required this.categoria});
}

class UpdateCategoria extends CategoriaEvento {
  final Categoria categoria;

  UpdateCategoria({required this.categoria});
}

class DeleteCategoria extends CategoriaEvento {
  final Categoria categoria;

  DeleteCategoria({required this.categoria});
}

class ObtenerCategorias extends CategoriaEvento {
  final Categoria categoria;

  ObtenerCategorias({required this.categoria});
}

//Estados
class CategoriasEstado with EquatableMixin {
  final List<Categoria> categorias;
  String error = "";

  CategoriasEstado._() : categorias = [];

  CategoriasEstado({required this.categorias, this.error=""});

  @override
  List<Object?> get props => [categorias];
}

class MockVehiculosBlocDb extends Mock implements CategoriasBloc {}

//Bloc
class CategoriasBloc extends Bloc<CategoriaEvento, CategoriasEstado> {
  List<Categoria> _categorias = [];

  CategoriasBloc() : super(CategoriasEstado._()) {
    on<Categoriasinicializado>((event, emit) async {
      await DatabaseHelper().iniciarDatabase();
      _categorias = await getAllCategoriasFromDb();
      emit(CategoriasEstado(categorias: _categorias));
    });
    on<AddCategoria>(_addcategoria);
    on<UpdateCategoria>(_updateCategoria);
    on<DeleteCategoria>(_deleteCategoria);
  }

  void _addcategoria(AddCategoria event, Emitter<CategoriasEstado> emit) async {
    try {
      await DatabaseHelper().iniciarDatabase();
      _categorias = await insertCategoria(event.categoria);
      emit(CategoriasEstado(categorias: _categorias));
    } catch (e) {
      emitErrorSnackBar(emit, 'Error al agregar vehículo: $e');
    }
  }

  void _updateCategoria(UpdateCategoria event, Emitter<CategoriasEstado> emit) async {
    try {
      Categoria? editCategoria = await getCategoriaByNombre(event.categoria.nombre);
      print("editCategoria: $editCategoria");

      if (editCategoria != null) {
        _categorias = await updateCategoria(event.categoria);
        emit(CategoriasEstado(categorias: _categorias));
        print('Categoria actualizado con éxito!');
      } else {
        emitErrorSnackBar(emit, 'Categoria no encontrado para actualizar.');
      }
    } catch (e) {
      emitErrorSnackBar(emit, 'Error al actualizar el vehículo: $e');
    }
  }

  void _deleteCategoria(DeleteCategoria event, Emitter<CategoriasEstado> emit) async {
    try {
      List<Categoria> updatedList = await deleteCategoria(event.categoria);
      emit(CategoriasEstado(categorias: updatedList));
      print('categoria eliminada con éxito!');
    } catch (e) {
      emitErrorSnackBar(emit, 'Error al eliminar categoria: $e');
    }
  }

  
  void emitErrorSnackBar(Emitter<CategoriasEstado> emit, String errorMessage) {
    emit(CategoriasEstado(categorias: state.categorias, error: errorMessage)); // Mantener el estado actual  
  }



  Future<List<Categoria>> getAllCategoriasFromDb() async {
    final Database? db = await DatabaseHelper().database;

    if (db == null) {
      print('Error: Database not initialized.');
      return [];
    }

    List<Map<String, dynamic>> data = await db.query('categorias');
    List<Categoria> listaOriginal = data.map((e) {
      return Categoria(
          id: e['ID'],
          nombre: e['nombre']);
    }).toList();

    return listaOriginal;
  }

  Future<List<Categoria>> insertCategoria(Categoria categoria) async {
    final Database? db = await DatabaseHelper().database;

    if (db == null) {
      print('Error: Database not initialized.');
      return [];
    }
    await db.insert(
      'categorias',
      {
        'marca': categoria.nombre,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    List<Map<String, dynamic>> data = await db.query('categorias');
    List<Categoria> listaOriginal = data.map((e) {
      return Categoria(
        id: e['ID'],
        nombre: e['nombre'],
      );
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
        placa: vehiculoData['placa'],
        modelo: vehiculoData['modelo'],
        anio: vehiculoData['anio'],
        color: vehiculoData['color'],
      );
    } else {
      print('Vehículo con id $id no encontrado.');
      return null;
    }
  }

  Future<Categoria?> getCategoriaByNombre(String nombre) async {
    final Database? db = await DatabaseHelper().database;

    if (db == null) {
      print('Error: Database not initialized.');
      return null;
    }

    List<Map<String, dynamic>> data = await db.query(
      'categorias',
      where:
          'nombre = ?', 
      whereArgs: [nombre],
    );

    if (data.isNotEmpty) {
      Map<String, dynamic> categoriaData = data.first;
      return Categoria(
        id: categoriaData['ID'],
        nombre: categoriaData['nombre'],
      );
    } else {
      print('Categoria con nombre $nombre no encontrada.');
      return null;
    }
  }

  Future<List<Categoria>> updateCategoria(Categoria? categoria) async {
    final Database? db = await DatabaseHelper().database;
    print("entro al update");
    if (categoria == null) {
      print("no hay categoria");
      return [];
    }

    if (db == null) {
      print('Error: Database not initialized.');
      return [];
    }

    await db.update(
      'categorias',
      {
        'nombre': categoria.nombre,
      },
      where: 'ID = ?', 
      whereArgs: [categoria.id], 
    );

    List<Map<String, dynamic>> data = await db.query('categorias');
    List<Categoria> listaOriginal = data.map((e) {
      return Categoria(
        id: e['ID'],
        nombre: e['nombre'],
      );
    }).toList();

    return listaOriginal;
  }

  Future<List<Categoria>> deleteCategoria(Categoria categoria) async {
    final Database? db = await DatabaseHelper().database;

    if (db == null) {
      print('Error: Database not initialized.');
      return [];
    }

    await db.delete(
      'categorias',
      where: 'ID = ?',
      whereArgs: [categoria.id], 
    );

    List<Map<String, dynamic>> data = await db.query('categoria');
    List<Categoria> updatedList = data.map((e) {
      return Categoria(
        id: e['ID'],
        nombre: e['nombre']
      );
    }).toList();

    return updatedList;
  }
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
        placa: maps[index]['placa'],
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
