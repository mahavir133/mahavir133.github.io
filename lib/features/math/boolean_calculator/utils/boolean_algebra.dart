class BooleanAlgebra {
  static List<String> generateTruthTable(String expression, List<String> vars) {
    List<String> results = [];
    int rows = 1 << vars.length; // 2^n

    // Header
    results.add('${vars.join(' | ')} | Result');
    results.add('-' * (vars.length * 4 + 10));

    for (int i = 0; i < rows; i++) {
      Map<String, bool> values = {};
      List<String> rowVals = [];
      for (int j = 0; j < vars.length; j++) {
        bool val = (i & (1 << (vars.length - 1 - j))) != 0;
        values[vars[j]] = val;
        rowVals.add(val ? '1' : '0');
      }

      bool res = _evaluate(expression, values);
      results.add('${rowVals.join(' | ')} | ${res ? '1' : '0'}');
    }
    return results;
  }

  static bool _evaluate(String exp, Map<String, bool> values) {
    // Basic substitution
    String evalStr = exp.toUpperCase();
    evalStr = evalStr.replaceAll('AND', '&');
    evalStr = evalStr.replaceAll('OR', '|');
    evalStr = evalStr.replaceAll('NOT', '!');
    evalStr = evalStr.replaceAll('XOR', '^');

    for (var k in values.keys) {
      evalStr = evalStr.replaceAll(k.toUpperCase(), values[k]! ? 'T' : 'F');
    }

    return _parse(evalStr);
  }

  // Very simple boolean parser using dart core mechanics or simple string reduction
  // Since we don't have eval(), we reduce the string manually
  static bool _parse(String s) {
    s = s.replaceAll(' ', '');
    // Evaluate parentheses first
    while (s.contains('(')) {
      int end = s.indexOf(')');
      int start = s.substring(0, end).lastIndexOf('(');
      bool inner = _parse(s.substring(start + 1, end));
      s = s.substring(0, start) + (inner ? 'T' : 'F') + s.substring(end + 1);
    }

    // Evaluate NOT
    while (s.contains('!')) {
      int idx = s.indexOf('!');
      if (idx + 1 < s.length) {
        bool val = s[idx + 1] == 'T';
        s = s.substring(0, idx) + (!val ? 'T' : 'F') + s.substring(idx + 2);
      } else {
        break;
      }
    }

    // Evaluate AND
    while (s.contains('&')) {
      int idx = s.indexOf('&');
      bool left = s[idx - 1] == 'T';
      bool right = s[idx + 1] == 'T';
      s =
          s.substring(0, idx - 1) +
          ((left && right) ? 'T' : 'F') +
          s.substring(idx + 2);
    }

    // Evaluate XOR
    while (s.contains('^')) {
      int idx = s.indexOf('^');
      bool left = s[idx - 1] == 'T';
      bool right = s[idx + 1] == 'T';
      s =
          s.substring(0, idx - 1) +
          ((left ^ right) ? 'T' : 'F') +
          s.substring(idx + 2);
    }

    // Evaluate OR
    while (s.contains('|')) {
      int idx = s.indexOf('|');
      bool left = s[idx - 1] == 'T';
      bool right = s[idx + 1] == 'T';
      s =
          s.substring(0, idx - 1) +
          ((left || right) ? 'T' : 'F') +
          s.substring(idx + 2);
    }

    return s == 'T';
  }
}
