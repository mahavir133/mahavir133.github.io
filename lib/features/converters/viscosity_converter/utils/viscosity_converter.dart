class ViscosityConverter {
  static final Map<String, double> _dynamicToPaS = {
    'Pa·s': 1.0,
    'Poise (P)': 0.1,
    'Centipoise (cP)': 0.001,
  };

  static final Map<String, double> _kinematicToM2S = {
    'm²/s': 1.0,
    'Stokes (St)': 0.0001,
    'Centistokes (cSt)': 0.000001,
  };

  static List<String> get dynamicUnits => _dynamicToPaS.keys.toList();
  static List<String> get kinematicUnits => _kinematicToM2S.keys.toList();
  static List<String> get allUnits => [...dynamicUnits, ...kinematicUnits];

  static double convert({
    required double value,
    required String from,
    required String to,
    double?
    densityKgM3, // Required only if crossing between dynamic and kinematic
  }) {
    if (from == to) return value;

    bool fromDynamic = _dynamicToPaS.containsKey(from);
    bool toDynamic = _dynamicToPaS.containsKey(to);

    // 1. Same category (Dynamic -> Dynamic)
    if (fromDynamic && toDynamic) {
      double inPas = value * _dynamicToPaS[from]!;
      return inPas / _dynamicToPaS[to]!;
    }

    // 2. Same category (Kinematic -> Kinematic)
    if (!fromDynamic && !toDynamic) {
      double inM2s = value * _kinematicToM2S[from]!;
      return inM2s / _kinematicToM2S[to]!;
    }

    // 3. Crossing categories
    if (densityKgM3 == null || densityKgM3 <= 0) {
      throw Exception("Fluid Density required for this conversion.");
    }

    if (fromDynamic && !toDynamic) {
      // Dynamic -> Kinematic: v = u / p
      double inPas = value * _dynamicToPaS[from]!;
      double inM2s = inPas / densityKgM3;
      return inM2s / _kinematicToM2S[to]!;
    } else {
      // Kinematic -> Dynamic: u = v * p
      double inM2s = value * _kinematicToM2S[from]!;
      double inPas = inM2s * densityKgM3;
      return inPas / _dynamicToPaS[to]!;
    }
  }
}
