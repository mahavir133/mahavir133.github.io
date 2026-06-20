import 'dart:math';

class Vector3D {
  final double x, y, z;

  Vector3D(this.x, this.y, this.z);

  Vector3D operator +(Vector3D other) =>
      Vector3D(x + other.x, y + other.y, z + other.z);
  Vector3D operator -(Vector3D other) =>
      Vector3D(x - other.x, y - other.y, z - other.z);

  double dot(Vector3D other) => x * other.x + y * other.y + z * other.z;

  Vector3D cross(Vector3D other) {
    return Vector3D(
      y * other.z - z * other.y,
      z * other.x - x * other.z,
      x * other.y - y * other.x,
    );
  }

  double get magnitude => sqrt(x * x + y * y + z * z);

  double angleBetween(Vector3D other) {
    double m1 = magnitude;
    double m2 = other.magnitude;
    if (m1 == 0 || m2 == 0) return 0;
    double cosTheta = dot(other) / (m1 * m2);
    // Clamp to avoid precision errors leading to NaN in acos
    cosTheta = cosTheta.clamp(-1.0, 1.0);
    return acos(cosTheta) * 180 / pi; // Returns degrees
  }

  @override
  String toString() {
    return '[${x.toStringAsFixed(2)}, ${y.toStringAsFixed(2)}, ${z.toStringAsFixed(2)}]';
  }
}
