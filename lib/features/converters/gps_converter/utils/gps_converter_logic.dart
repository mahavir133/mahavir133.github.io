import 'package:utm/utm.dart' as utm_pkg;
import 'package:mgrs_dart/mgrs_dart.dart';
import 'package:open_location_code/open_location_code.dart';
import 'package:latlong2/latlong.dart';

class GpsCoordinate {
  final double latitude;
  final double longitude;

  GpsCoordinate(this.latitude, this.longitude);

  // Decimal Degrees
  String get decimalDegrees =>
      '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';

  // Degrees, Minutes, Seconds
  String get dms {
    return '${_toDMS(latitude, isLat: true)}, ${_toDMS(longitude, isLat: false)}';
  }

  // UTM
  String get utm {
    try {
      final u = utm_pkg.UTM.fromLatLon(lat: latitude, lon: longitude);
      return '${u.zoneNumber}${u.zoneLetter} ${u.easting.toStringAsFixed(2)} ${u.northing.toStringAsFixed(2)}';
    } catch (e) {
      return 'Invalid UTM';
    }
  }

  // MGRS
  String get mgrs {
    try {
      return Mgrs.forward([longitude, latitude], 5);
    } catch (e) {
      return 'Invalid MGRS';
    }
  }

  // Plus Code (Open Location Code)
  String get plusCode {
    try {
      return PlusCode.encode(LatLng(latitude, longitude)).toString();
    } catch (e) {
      return 'Invalid Plus Code';
    }
  }

  // Parsers from different formats to DD
  static GpsCoordinate? fromDD(String latStr, String lonStr) {
    final lat = double.tryParse(latStr);
    final lon = double.tryParse(lonStr);
    if (lat != null && lon != null) {
      return GpsCoordinate(lat, lon);
    }
    return null;
  }

  static GpsCoordinate? fromDMS(
    int latD,
    int latM,
    double latS,
    String latHem,
    int lonD,
    int lonM,
    double lonS,
    String lonHem,
  ) {
    double lat = latD + (latM / 60) + (latS / 3600);
    if (latHem.toUpperCase() == 'S') lat = -lat;

    double lon = lonD + (lonM / 60) + (lonS / 3600);
    if (lonHem.toUpperCase() == 'W') lon = -lon;

    return GpsCoordinate(lat, lon);
  }

  static GpsCoordinate? fromUTM(
    int zone,
    String letter,
    double easting,
    double northing,
  ) {
    try {
      final latlon = utm_pkg.UTM.fromUtm(
        easting: easting,
        northing: northing,
        zoneNumber: zone,
        zoneLetter: letter,
      );
      return GpsCoordinate(latlon.lat, latlon.lon);
    } catch (e) {
      return null;
    }
  }

  static GpsCoordinate? fromMGRS(String mgrsStr) {
    try {
      final point = Mgrs.inverse(mgrsStr.trim());
      // point is [lon, lat]
      return GpsCoordinate(point[1], point[0]);
    } catch (e) {
      return null;
    }
  }

  static GpsCoordinate? fromPlusCode(String code) {
    try {
      final decoded = PlusCode(code.trim()).decode();
      return GpsCoordinate(decoded.center.latitude, decoded.center.longitude);
    } catch (e) {
      return null;
    }
  }

  static String _toDMS(double val, {required bool isLat}) {
    final absVal = val.abs();
    final d = absVal.floor();
    final minFloat = (absVal - d) * 60;
    final m = minFloat.floor();
    final s = (minFloat - m) * 60;

    final hem = isLat ? (val >= 0 ? 'N' : 'S') : (val >= 0 ? 'E' : 'W');

    return '$d° $m\' ${s.toStringAsFixed(2)}" $hem';
  }
}
