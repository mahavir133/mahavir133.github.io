class BaseConverterResult {
  final String binary;
  final String octal;
  final String decimal;
  final String hex;
  final String customBaseResult;

  BaseConverterResult({
    required this.binary,
    required this.octal,
    required this.decimal,
    required this.hex,
    required this.customBaseResult,
  });
}

class BaseConverter {
  static BaseConverterResult convert({
    required String value,
    required int fromBase,
    required int toCustomBase,
  }) {
    if (value.isEmpty) {
      return BaseConverterResult(
        binary: '',
        octal: '',
        decimal: '',
        hex: '',
        customBaseResult: '',
      );
    }

    try {
      // Parse the value from the given base to decimal
      final BigInt decimalValue = BigInt.parse(value, radix: fromBase);

      return BaseConverterResult(
        binary: decimalValue.toRadixString(2).toUpperCase(),
        octal: decimalValue.toRadixString(8).toUpperCase(),
        decimal: decimalValue.toRadixString(10).toUpperCase(),
        hex: decimalValue.toRadixString(16).toUpperCase(),
        customBaseResult: decimalValue
            .toRadixString(toCustomBase)
            .toUpperCase(),
      );
    } catch (e) {
      // Invalid input for the given base
      return BaseConverterResult(
        binary: 'Error',
        octal: 'Error',
        decimal: 'Error',
        hex: 'Error',
        customBaseResult: 'Error',
      );
    }
  }

  static String bitwiseOp(String val1, String val2, int base, String op) {
    try {
      final BigInt a = BigInt.parse(val1, radix: base);
      final BigInt b = BigInt.parse(val2, radix: base);
      BigInt result;

      switch (op) {
        case 'AND':
          result = a & b;
          break;
        case 'OR':
          result = a | b;
          break;
        case 'XOR':
          result = a ^ b;
          break;
        default:
          return 'Error';
      }
      return result.toRadixString(base).toUpperCase();
    } catch (e) {
      return 'Error';
    }
  }
}
