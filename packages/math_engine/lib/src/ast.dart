abstract class Expression {
  R accept<R, C>(ExpressionVisitor<R, C> visitor, C context);
  String toDisplayString();
}

abstract class ExpressionVisitor<R, C> {
  R visitNumber(NumberNode node, C context);
  R visitVariable(VariableNode node, C context);
  R visitConstant(ConstantNode node, C context);
  R visitUnaryOp(UnaryOpNode node, C context);
  R visitPostfixOp(PostfixOpNode node, C context);
  R visitBinaryOp(BinaryOpNode node, C context);
  R visitFunction(FunctionNode node, C context);
  R visitEquation(EquationNode node, C context);
}

enum NumberBase { bin, oct, dec, hex }

class NumberNode extends Expression {
  final double value;
  final String rawValue;
  final NumberBase base;

  NumberNode(this.value, this.rawValue, this.base);

  @override
  R accept<R, C>(ExpressionVisitor<R, C> visitor, C context) {
    return visitor.visitNumber(this, context);
  }

  @override
  String toDisplayString() => rawValue;
}

class VariableNode extends Expression {
  final String name;

  VariableNode(this.name);

  @override
  R accept<R, C>(ExpressionVisitor<R, C> visitor, C context) {
    return visitor.visitVariable(this, context);
  }

  @override
  String toDisplayString() => name;
}

class ConstantNode extends Expression {
  final String name;

  ConstantNode(this.name);

  @override
  R accept<R, C>(ExpressionVisitor<R, C> visitor, C context) {
    return visitor.visitConstant(this, context);
  }

  @override
  String toDisplayString() {
    switch (name.toLowerCase()) {
      case 'pi':
        return 'π';
      case 'e':
        return 'e';
      case 'avogadro':
        return 'N_A';
      case 'c':
        return 'c';
      case 'h':
        return 'h';
      default:
        return name;
    }
  }
}

class UnaryOpNode extends Expression {
  final String operator;
  final Expression expression;

  UnaryOpNode(this.operator, this.expression);

  @override
  R accept<R, C>(ExpressionVisitor<R, C> visitor, C context) {
    return visitor.visitUnaryOp(this, context);
  }

  @override
  String toDisplayString() {
    if (operator == '~') {
      return '~$expression';
    }
    return '$operator(${expression.toDisplayString()})';
  }
}

class PostfixOpNode extends Expression {
  final String operator;
  final Expression expression;

  PostfixOpNode(this.operator, this.expression);

  @override
  R accept<R, C>(ExpressionVisitor<R, C> visitor, C context) {
    return visitor.visitPostfixOp(this, context);
  }

  @override
  String toDisplayString() {
    return '${expression.toDisplayString()}$operator';
  }
}

class BinaryOpNode extends Expression {
  final Expression left;
  final String operator;
  final Expression right;

  BinaryOpNode(this.left, this.operator, this.right);

  @override
  R accept<R, C>(ExpressionVisitor<R, C> visitor, C context) {
    return visitor.visitBinaryOp(this, context);
  }

  @override
  String toDisplayString() {
    return '(${left.toDisplayString()} $operator ${right.toDisplayString()})';
  }
}

class FunctionNode extends Expression {
  final String name;
  final List<Expression> arguments;

  FunctionNode(this.name, this.arguments);

  @override
  R accept<R, C>(ExpressionVisitor<R, C> visitor, C context) {
    return visitor.visitFunction(this, context);
  }

  @override
  String toDisplayString() {
    final argsStr = arguments.map((a) => a.toDisplayString()).join(', ');
    return '$name($argsStr)';
  }
}

class EquationNode extends Expression {
  final Expression left;
  final Expression right;

  EquationNode(this.left, this.right);

  @override
  R accept<R, C>(ExpressionVisitor<R, C> visitor, C context) {
    return visitor.visitEquation(this, context);
  }

  @override
  String toDisplayString() {
    return '${left.toDisplayString()} = ${right.toDisplayString()}';
  }
}
