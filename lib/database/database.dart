import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class DatabaseHelper {
  Database? dbGestor;

  Future<Database?> get database async {
    dbGestor ??= await iniciarDatabase();
    return dbGestor;
  }

  Future<Database?> iniciarDatabase() async {
    // WidgetsFlutterBinding.ensureInitialized();
    // sqfliteFfiInit();

    var fabricaBaseDatos = databaseFactory; //databasefactory
    String rutaBaseDatos;

    try {
      rutaBaseDatos =
          await fabricaBaseDatos.getDatabasesPath() + "/databaseee.db";
      return dbGestor = await fabricaBaseDatos.openDatabase(
        rutaBaseDatos,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, version) async {
            await db.execute(
              'CREATE TABLE vehiculos (ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, marca TEXT(35), modelo TEXT(35), anio TEXT(35), color TEXT(35));',
            );
            // await db.execute('CREATE TABLE gastos (ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, tipoGasto TEXT(35), monto DECIMAL, fecha DATE, descripcion TEXT(80), vehiculoId INTEGER FOREIGN KEY (vehiculoId) REFERENCES vehiculos(id));',);
            await db.execute('CREATE TABLE gastos ('
                'ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, '
                'tipoGasto TEXT(35), '
                'monto DOUBLE, '
                'fecha DATE, '
                'descripcion TEXT(80), '
                'vehiculoId INTEGER, '
                'FOREIGN KEY (vehiculoId) REFERENCES vehiculos(ID)'
                ');');
          },
        ),
      );
    } catch (e) {
      // Handle initialization error
      print('Error initializing database: $e');
      return null;
    }
  }
}











      // if (kIsWeb) {
      //   databaseFactory = databaseFactoryFfiWeb;
      //   rutaBaseDatos = "web/gastosdb.db"; // Provide a valid web path
      // } else {
      //   rutaBaseDatos = await fabricaBaseDatos.getDatabasesPath() + "/databasee.db";
      // }