import 'dart:math';

enum LoadType {
  point,
  udl,
} // point = Center Point Load, udl = Uniformly Distributed Load

class BeamResult {
  final double maxShear; // kN or kips
  final double maxMoment; // kN*m or kip*ft
  final double maxDeflection; // mm or inches

  BeamResult({
    required this.maxShear,
    required this.maxMoment,
    required this.maxDeflection,
  });
}

class BeamLogic {
  static BeamResult calculate({
    required double length, // m or ft
    required double load, // kN or kips (Point) OR kN/m or kips/ft (UDL)
    required double modulusE, // GPa or ksi
    required double inertiaI, // cm^4 or in^4
    required LoadType loadType,
    required bool isMetric,
  }) {
    if (length <= 0 || modulusE <= 0 || inertiaI <= 0) {
      return BeamResult(maxShear: 0, maxMoment: 0, maxDeflection: 0);
    }

    double maxShear = 0;
    double maxMoment = 0;
    double maxDeflection = 0;

    if (isMetric) {
      // METRIC
      // L in meters (m)
      // Load in kN or kN/m
      // E in GPa (1 GPa = 10^6 kN/m^2)
      // I in cm^4 (1 cm^4 = 10^-8 m^4)

      double E_kNm2 = modulusE * pow(10, 6);
      double I_m4 = inertiaI * pow(10, -8);

      if (loadType == LoadType.point) {
        // P = load
        maxShear = load / 2;
        maxMoment = (load * length) / 4;
        // Deflection in meters = (P * L^3) / (48 * E * I)
        double deflMeters = (load * pow(length, 3)) / (48 * E_kNm2 * I_m4);
        maxDeflection = deflMeters * 1000; // convert to mm
      } else {
        // w = load
        maxShear = (load * length) / 2;
        maxMoment = (load * pow(length, 2)) / 8;
        // Deflection in meters = (5 * w * L^4) / (384 * E * I)
        double deflMeters = (5 * load * pow(length, 4)) / (384 * E_kNm2 * I_m4);
        maxDeflection = deflMeters * 1000; // convert to mm
      }
    } else {
      // IMPERIAL
      // L in feet (ft) -> L_in = L * 12
      // Load in kips or kips/ft -> if UDL, w_in = load / 12 (kips/in)
      // E in ksi (kips/in^2)
      // I in in^4

      double L_in = length * 12;

      if (loadType == LoadType.point) {
        // P = load (kips)
        maxShear = load / 2;
        maxMoment = (load * length) / 4; // kip*ft
        maxDeflection =
            (load * pow(L_in, 3)) / (48 * modulusE * inertiaI); // inches
      } else {
        // w = load (kips/ft)
        double w_in = load / 12.0; // kips/in
        maxShear = (load * length) / 2;
        maxMoment = (load * pow(length, 2)) / 8; // kip*ft
        maxDeflection =
            (5 * w_in * pow(L_in, 4)) / (384 * modulusE * inertiaI); // inches
      }
    }

    return BeamResult(
      maxShear: maxShear,
      maxMoment: maxMoment,
      maxDeflection: maxDeflection,
    );
  }
}
