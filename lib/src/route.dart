import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<List<LatLng>> loadRoute() async {
  return await _loadLatLngs('assets/data/route.csv');
}

Future<List<LatLng>> loadSteps() async {
  return await _loadLatLngs('assets/data/steps.csv');
}

Future<List<LatLng>> _loadLatLngs(String fileName) async {
  final buffer = await rootBundle.loadString(fileName);
  final csv = CsvToListConverter().convert(buffer, eol: '\n');
  return csv.map((e) => LatLng(e[0], e[1])).toList();
}
