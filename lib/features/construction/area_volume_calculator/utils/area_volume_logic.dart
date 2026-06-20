import 'dart:math';

enum ShapeType {
  triangle,
  circle,
  trapezoid,
  ellipse,
  polygon,
  sphere,
  cone,
  cylinder,
  torus,
  frustum,
}

class AreaVolumeLogic {
  static double calculateArea(ShapeType type, Map<String, double> params) {
    switch (type) {
      case ShapeType.triangle:
        final b = params['base'] ?? 0;
        final h = params['height'] ?? 0;
        return 0.5 * b * h;
      case ShapeType.circle:
        final r = params['radius'] ?? 0;
        return pi * r * r;
      case ShapeType.trapezoid:
        final a = params['a'] ?? 0;
        final b = params['b'] ?? 0;
        final h = params['height'] ?? 0;
        return 0.5 * (a + b) * h;
      case ShapeType.ellipse:
        final a = params['a'] ?? 0;
        final b = params['b'] ?? 0;
        return pi * a * b;
      case ShapeType.polygon:
        final n = params['sides'] ?? 3;
        final s = params['sideLength'] ?? 0;
        if (n < 3) return 0;
        return (n * s * s) / (4 * tan(pi / n));
      default:
        return 0;
    }
  }

  static double calculateVolume(ShapeType type, Map<String, double> params) {
    switch (type) {
      case ShapeType.sphere:
        final r = params['radius'] ?? 0;
        return (4 / 3) * pi * pow(r, 3);
      case ShapeType.cone:
        final r = params['radius'] ?? 0;
        final h = params['height'] ?? 0;
        return (1 / 3) * pi * r * r * h;
      case ShapeType.cylinder:
        final r = params['radius'] ?? 0;
        final h = params['height'] ?? 0;
        return pi * r * r * h;
      case ShapeType.torus:
        final majorR = params['majorRadius'] ?? 0;
        final minorR = params['minorRadius'] ?? 0;
        return (pi * minorR * minorR) * (2 * pi * majorR);
      case ShapeType.frustum:
        final R = params['bottomRadius'] ?? 0;
        final r = params['topRadius'] ?? 0;
        final h = params['height'] ?? 0;
        return (1 / 3) * pi * h * (R * R + R * r + r * r);
      default:
        return 0;
    }
  }

  static double calculateSurfaceArea(
    ShapeType type,
    Map<String, double> params,
  ) {
    switch (type) {
      case ShapeType.sphere:
        final r = params['radius'] ?? 0;
        return 4 * pi * r * r;
      case ShapeType.cone:
        final r = params['radius'] ?? 0;
        final h = params['height'] ?? 0;
        final slant = sqrt(r * r + h * h);
        return pi * r * (r + slant);
      case ShapeType.cylinder:
        final r = params['radius'] ?? 0;
        final h = params['height'] ?? 0;
        return 2 * pi * r * (r + h);
      case ShapeType.torus:
        final majorR = params['majorRadius'] ?? 0;
        final minorR = params['minorRadius'] ?? 0;
        return 4 * pi * pi * majorR * minorR;
      case ShapeType.frustum:
        final R = params['bottomRadius'] ?? 0;
        final r = params['topRadius'] ?? 0;
        final h = params['height'] ?? 0;
        final slant = sqrt(pow(R - r, 2) + h * h);
        return pi * (R * R + r * r + slant * (R + r));
      default:
        return 0;
    }
  }

  static List<String> getParamsForShape(ShapeType type) {
    switch (type) {
      case ShapeType.triangle:
        return ['base', 'height'];
      case ShapeType.circle:
        return ['radius'];
      case ShapeType.trapezoid:
        return ['a', 'b', 'height'];
      case ShapeType.ellipse:
        return ['a', 'b'];
      case ShapeType.polygon:
        return ['sides', 'sideLength'];
      case ShapeType.sphere:
        return ['radius'];
      case ShapeType.cone:
        return ['radius', 'height'];
      case ShapeType.cylinder:
        return ['radius', 'height'];
      case ShapeType.torus:
        return ['majorRadius', 'minorRadius'];
      case ShapeType.frustum:
        return ['bottomRadius', 'topRadius', 'height'];
    }
  }
}
