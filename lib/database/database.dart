import 'dart:io';

import 'package:moor/moor.dart';
import 'package:moor_ffi/moor_ffi.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'package:quake/database/tables/tables.dart';

part 'database.g.dart';

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return VmDatabase(file);
  });
}

@UseMoor(tables: tables)
class Database extends _$Database {
  @override
  int get schemaVersion => 1;

  Database() : super(_openConnection());

  Future<List<Earthquake>> get allEarthquakes => select(earthquakes).get();

  Future deleteAllEarthquakes() => delete(earthquakes).go();
}
