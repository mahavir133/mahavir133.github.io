class MatrixCalculator {
  static List<List<double>> add(List<List<double>> a, List<List<double>> b) {
    if (a.length != b.length || a[0].length != b[0].length) {
      throw Exception('Matrices must have the same dimensions.');
    }
    return List.generate(a.length, (i) {
      return List.generate(a[0].length, (j) => a[i][j] + b[i][j]);
    });
  }

  static List<List<double>> subtract(
    List<List<double>> a,
    List<List<double>> b,
  ) {
    if (a.length != b.length || a[0].length != b[0].length) {
      throw Exception('Matrices must have the same dimensions.');
    }
    return List.generate(a.length, (i) {
      return List.generate(a[0].length, (j) => a[i][j] - b[i][j]);
    });
  }

  static List<List<double>> multiply(
    List<List<double>> a,
    List<List<double>> b,
  ) {
    if (a[0].length != b.length) {
      throw Exception('Number of columns of A must equal number of rows of B.');
    }
    List<List<double>> result = List.generate(
      a.length,
      (_) => List.filled(b[0].length, 0.0),
    );
    for (int i = 0; i < a.length; i++) {
      for (int j = 0; j < b[0].length; j++) {
        for (int k = 0; k < a[0].length; k++) {
          result[i][j] += a[i][k] * b[k][j];
        }
      }
    }
    return result;
  }

  static List<List<double>> transpose(List<List<double>> a) {
    return List.generate(a[0].length, (i) {
      return List.generate(a.length, (j) => a[j][i]);
    });
  }

  static double determinant(List<List<double>> matrix) {
    int n = matrix.length;
    if (n != matrix[0].length) throw Exception('Matrix must be square.');
    if (n == 1) return matrix[0][0];
    if (n == 2)
      return matrix[0][0] * matrix[1][1] - matrix[0][1] * matrix[1][0];

    // Copy matrix to avoid modifying original
    List<List<double>> a = List.generate(n, (i) => List.from(matrix[i]));
    double det = 1;

    for (int i = 0; i < n; i++) {
      int pivot = i;
      for (int j = i + 1; j < n; j++) {
        if (a[j][i].abs() > a[pivot][i].abs()) pivot = j;
      }
      if (a[pivot][i] == 0) return 0;
      if (pivot != i) {
        List<double> temp = a[i];
        a[i] = a[pivot];
        a[pivot] = temp;
        det = -det;
      }
      det *= a[i][i];
      for (int j = i + 1; j < n; j++) {
        double factor = a[j][i] / a[i][i];
        for (int k = i + 1; k < n; k++) {
          a[j][k] -= factor * a[i][k];
        }
      }
    }
    return det;
  }

  static List<List<double>> inverse(List<List<double>> matrix) {
    int n = matrix.length;
    if (n != matrix[0].length) throw Exception('Matrix must be square.');

    // Gauss-Jordan elimination
    List<List<double>> a = List.generate(n, (i) => List.from(matrix[i]));
    List<List<double>> inv = List.generate(
      n,
      (i) => List.generate(n, (j) => i == j ? 1.0 : 0.0),
    );

    for (int i = 0; i < n; i++) {
      double pivot = a[i][i];
      if (pivot == 0) throw Exception('Matrix is not invertible (singular).');

      for (int j = 0; j < n; j++) {
        a[i][j] /= pivot;
        inv[i][j] /= pivot;
      }
      for (int j = 0; j < n; j++) {
        if (i != j) {
          double factor = a[j][i];
          for (int k = 0; k < n; k++) {
            a[j][k] -= factor * a[i][k];
            inv[j][k] -= factor * inv[i][k];
          }
        }
      }
    }
    return inv;
  }

  static String matrixToString(List<List<double>> matrix) {
    return matrix
        .map((row) => '[${row.map((e) => e.toStringAsFixed(2)).join(', ')}]')
        .join('\n');
  }
}
