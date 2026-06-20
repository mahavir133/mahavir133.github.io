class TempResult {
  final double value;
  final String formula;

  TempResult(this.value, this.formula);
}

class TemperatureConverter {
  static final List<String> units = [
    'Celsius (°C)',
    'Fahrenheit (°F)',
    'Kelvin (K)',
    'Rankine (°Ra)',
    'Delisle (°De)',
    'Newton (°N)',
    'Réaumur (°Ré)',
    'Rømer (°Rø)',
  ];

  static TempResult convert(double value, String from, String to) {
    if (from == to)
      return TempResult(value, 'No conversion needed: $value = $value');

    // 1. Convert to Celsius first
    double c = 0;
    String step1Formula = "";

    switch (from) {
      case 'Celsius (°C)':
        c = value;
        step1Formula = "C = $value";
        break;
      case 'Fahrenheit (°F)':
        c = (value - 32) * 5 / 9;
        step1Formula = "C = ($value - 32) × 5/9";
        break;
      case 'Kelvin (K)':
        c = value - 273.15;
        step1Formula = "C = $value - 273.15";
        break;
      case 'Rankine (°Ra)':
        c = (value - 491.67) * 5 / 9;
        step1Formula = "C = ($value - 491.67) × 5/9";
        break;
      case 'Delisle (°De)':
        c = 100 - value * 2 / 3;
        step1Formula = "C = 100 - $value × 2/3";
        break;
      case 'Newton (°N)':
        c = value * 100 / 33;
        step1Formula = "C = $value × 100/33";
        break;
      case 'Réaumur (°Ré)':
        c = value * 5 / 4;
        step1Formula = "C = $value × 5/4";
        break;
      case 'Rømer (°Rø)':
        c = (value - 7.5) * 40 / 21;
        step1Formula = "C = ($value - 7.5) × 40/21";
        break;
    }

    // 2. Convert from Celsius to Target
    double result = 0;
    String finalFormula = "";

    switch (to) {
      case 'Celsius (°C)':
        result = c;
        finalFormula = step1Formula;
        break;
      case 'Fahrenheit (°F)':
        result = c * 9 / 5 + 32;
        finalFormula = from == 'Celsius (°C)'
            ? "°F = ($value × 9/5) + 32"
            : "$step1Formula\n°F = (${c.toStringAsFixed(2)} × 9/5) + 32";
        break;
      case 'Kelvin (K)':
        result = c + 273.15;
        finalFormula = from == 'Celsius (°C)'
            ? "K = $value + 273.15"
            : "$step1Formula\nK = ${c.toStringAsFixed(2)} + 273.15";
        break;
      case 'Rankine (°Ra)':
        result = (c + 273.15) * 9 / 5;
        finalFormula = from == 'Celsius (°C)'
            ? "°Ra = ($value + 273.15) × 9/5"
            : "$step1Formula\n°Ra = (${c.toStringAsFixed(2)} + 273.15) × 9/5";
        break;
      case 'Delisle (°De)':
        result = (100 - c) * 3 / 2;
        finalFormula = from == 'Celsius (°C)'
            ? "°De = (100 - $value) × 3/2"
            : "$step1Formula\n°De = (100 - ${c.toStringAsFixed(2)}) × 3/2";
        break;
      case 'Newton (°N)':
        result = c * 33 / 100;
        finalFormula = from == 'Celsius (°C)'
            ? "°N = $value × 33/100"
            : "$step1Formula\n°N = ${c.toStringAsFixed(2)} × 33/100";
        break;
      case 'Réaumur (°Ré)':
        result = c * 4 / 5;
        finalFormula = from == 'Celsius (°C)'
            ? "°Ré = $value × 4/5"
            : "$step1Formula\n°Ré = ${c.toStringAsFixed(2)} × 4/5";
        break;
      case 'Rømer (°Rø)':
        result = c * 21 / 40 + 7.5;
        finalFormula = from == 'Celsius (°C)'
            ? "°Rø = $value × 21/40 + 7.5"
            : "$step1Formula\n°Rø = ${c.toStringAsFixed(2)} × 21/40 + 7.5";
        break;
    }

    return TempResult(result, finalFormula);
  }
}
