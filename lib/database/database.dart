import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class Database_helper {
  late Database dbGestor;

  Future<void> iniciarDatabase() async {
    WidgetsFlutterBinding.ensureInitialized();
    sqfliteFfiInit();

    var fabricaBaseDatos = databaseFactoryFfi;
    String rutaBaseDatos =
        '${await fabricaBaseDatos.getDatabasesPath()}/gastosdb.db';

    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
      rutaBaseDatos = "C:\Users\practicanteinfra2\Documents\Jose Carlos\control_gastos_carros/gastosdb.db";
    }
    dbGestor = await fabricaBaseDatos.openDatabase(rutaBaseDatos,
        options: OpenDatabaseOptions(
            version: 1,
            onCreate: (db, version) async {
              await db.execute(
                  'CREATE TABLE vehiculos (ID INTEGER PRIMARY KEY AUTOINCREMENT, marca TEXT(35), modelo TEXT(35), anio TEXT(35), color TEXT(35));');
            }));
  }
}
