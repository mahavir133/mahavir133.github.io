import 'dart:math';

enum ConcreteShape { slab, columnRound, columnSquare, footing, stairs }

class ConcreteResult {
  final double volumeCubicMeters;
  final double volumeCubicYards;
  final double volumeCubicFeet;
  final int bags60lb;
  final int bags80lb;

  ConcreteResult({
    required this.volumeCubicMeters,
    required this.volumeCubicYards,
    required this.volumeCubicFeet,
    required this.bags60lb,
    required this.bags80lb,
  });
}

class ConcreteLogic {
  static ConcreteResult calculate({
    required ConcreteShape shape,
    required Map<String, double> params,
    required bool isMetric,
    required double wastagePercent,
  }) {
    double volumeRaw =
        0; // Will be in cubic meters if metric, cubic feet if imperial.

    switch (shape) {
      case ConcreteShape.slab:
      case ConcreteShape.footing:
        final l = params['length'] ?? 0;
        final w = params['width'] ?? 0;
        final t = params['thickness'] ?? 0; // Note: assumed same unit as l,w
        volumeRaw = l * w * t;
        break;
      case ConcreteShape.columnRound:
        final d = params['diameter'] ?? 0;
        final h = params['height'] ?? 0;
        volumeRaw = pi * pow(d / 2, 2) * h;
        break;
      case ConcreteShape.columnSquare:
        final s = params['side'] ?? 0;
        final h = params['height'] ?? 0;
        volumeRaw = s * s * h;
        break;
      case ConcreteShape.stairs:
        final steps = params['steps'] ?? 0;
        final run = params['treadRun'] ?? 0;
        final rise = params['treadRise'] ?? 0;
        final w = params['width'] ?? 0;
        final throat = params['throatThickness'] ?? 0;

        final stepsVolume = steps * (run * rise / 2) * w;
        final baseLength = steps * run;
        final baseVolume =
            baseLength * throat * w; // approximation of the base slab
        volumeRaw = stepsVolume + baseVolume;
        break;
    }

    // Apply wastage
    volumeRaw = volumeRaw * (1 + (wastagePercent / 100));

    double volM3 = 0;
    double volCuFt = 0;

    if (isMetric) {
      volM3 = volumeRaw;
      volCuFt = volM3 * 35.3147;
    } else {
      volCuFt = volumeRaw;
      volM3 = volCuFt / 35.3147;
    }

    final volCuYd = volCuFt / 27.0;

    // Standard bags
    // 60 lb bag = 0.45 cu ft
    // 80 lb bag = 0.60 cu ft
    final bags60 = (volCuFt / 0.45).ceil();
    final bags80 = (volCuFt / 0.60).ceil();

    return ConcreteResult(
      volumeCubicMeters: volM3,
      volumeCubicYards: volCuYd,
      volumeCubicFeet: volCuFt,
      bags60lb: bags60,
      bags80lb: bags80,
    );
  }

  static List<String> getParamsForShape(ConcreteShape shape) {
    switch (shape) {
      case ConcreteShape.slab:
      case ConcreteShape.footing:
        return ['length', 'width', 'thickness'];
      case ConcreteShape.columnRound:
        return ['diameter', 'height'];
      case ConcreteShape.columnSquare:
        return ['side', 'height'];
      case ConcreteShape.stairs:
        return ['steps', 'treadRun', 'treadRise', 'width', 'throatThickness'];
    }
  }
}
