import 'dart:typed_data';
import 'dart:ui' as ui;

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

Future<Uint8List> getBytesFromAsset(String path, int width) async {
  ByteData data = await rootBundle.load(path);
  ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
      targetWidth: width);
  ui.FrameInfo fi = await codec.getNextFrame();
  return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
      .buffer
      .asUint8List();
}
