import 'package:expressions/expressions.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bryon Garcia',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff176b87),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const CalculatorPage(),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  static const _operators = {'+', '-', '*', '/'};
  static const _buttons = [
    ['C', '/', '*', '-'],
    ['7', '8', '9', '+'],
    ['4', '5', '6', '='],
    ['1', '2', '3', '0'],
  ];

  String _expression = '';
  String? _error;
  bool _hasResult = false;

  void _press(String value) {
    setState(() {
      if (value == 'C') {
        _expression = '';
        _error = null;
        _hasResult = false;
      } else if (value == '=') {
        _evaluate();
      } else if (_error != null) {
        _expression = _isOperator(value) ? '' : value;
        _error = null;
        _hasResult = false;
      } else if (_hasResult && !_isOperator(value)) {
        _expression = value;
        _hasResult = false;
      } else if (_isOperator(value)) {
        if (_expression.isEmpty) return;
        if (_hasResult) {
          _expression = _expression.split(' = ').last;
          _hasResult = false;
        }
        if (_isOperator(_expression[_expression.length - 1])) {
          _expression =
              '${_expression.substring(0, _expression.length - 1)}$value';
        } else {
          _expression += value;
        }
        _hasResult = false;
      } else {
        _expression += value;
        _hasResult = false;
      }
    });
  }

  void _evaluate() {
    if (_expression.isEmpty ||
        _isOperator(_expression[_expression.length - 1])) {
      _error = 'Enter a complete expression';
      return;
    }

    try {
      final parsed = Expression.parse(_expression);
      final result = const ExpressionEvaluator().eval(parsed, {});
      if (result is! num || !result.isFinite) {
        throw const FormatException('Invalid result');
      }
      _expression = '${_expression} = ${_formatResult(result)}';
      _hasResult = true;
      _error = null;
    } catch (_) {
      _error = 'Cannot calculate this expression';
    }
  }

  bool _isOperator(String value) => _operators.contains(value);

  String _formatResult(num result) {
    if (result == result.roundToDouble()) return result.toInt().toString();
    return result.toString();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final buttonValues = _buttons.expand((row) => row).toList();
    return Scaffold(
      backgroundColor: const Color(0xfff2f7f8),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Text(
                    'Bryon Garcia',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _Display(expression: _expression, error: _error),
                  const SizedBox(height: 20),
                  Expanded(
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: buttonValues.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.35,
                          ),
                      itemBuilder: (context, index) {
                        final value = buttonValues[index];
                        final isOperator = _isOperator(value) || value == '=';
                        return _CalculatorButton(
                          label: value,
                          isAccent: isOperator,
                          isClear: value == 'C',
                          onPressed: () => _press(value),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Display extends StatelessWidget {
  const _Display({required this.expression, required this.error});

  final String expression;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 142),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      decoration: BoxDecoration(
        color: const Color(0xff173f4d),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Align(
        alignment: Alignment.bottomRight,
        child: Text(
          error ?? (expression.isEmpty ? '0' : expression),
          key: const Key('calculator-display'),
          textAlign: TextAlign.right,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: error == null ? Colors.white : const Color(0xffffc7a9),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _CalculatorButton extends StatelessWidget {
  const _CalculatorButton({
    required this.label,
    required this.onPressed,
    this.isAccent = false,
    this.isClear = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isAccent;
  final bool isClear;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: isClear
            ? const Color(0xffffd8c7)
            : isAccent
            ? colors.primary
            : Colors.white,
        foregroundColor: isClear
            ? const Color(0xff9b3d20)
            : isAccent
            ? Colors.white
            : const Color(0xff173f4d),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
      ),
      child: Text(label),
    );
  }
}
