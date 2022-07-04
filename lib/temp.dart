import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ganak India',
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
      ),
      home: const MyHomePage(title: 'CALCULATOR'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String output = "0";
  String _output = "0";
  double num1 = 0.0;
  double num2 = 0.0;
  String operand = " ";

  buttonPressed(String buttonText) {
    if (buttonText == "CLEAR") {
      _output = "0";
      num1 = 0.0;
      num2 = 0.0;
      operand = "";
    } else if (buttonText == "+" ||
        buttonText == "-" ||
        buttonText == "x" ||
        buttonText == "/") {
      num1 = double.parse(output);

      operand = buttonText;

      _output = "0";
    } else if (buttonText == ".") {
      if (_output.contains(".")) {
        print("Already contain a decimal");
        return;
      } else {
        _output = _output + buttonText;
      }
    } else if (buttonText == "=") {
      num2 = double.parse(output);

      if (operand == "+") {
        _output = (num1 + num2).toString();
      }

      if (operand == "-") {
        _output = (num1 - num2).toString();
      }
      if (operand == "x") {
        _output = (num1 * num2).toString();
      }
      if (operand == "/") {
        _output = (num1 / num2).toString();
      }

      num1 = 0.0;
      num2 = 0.0;
      operand = "";
    } else {
      _output = _output + buttonText;
    }
    print(_output);
    setState(() {
      _output = double.parse(_output).toStringAsFixed(2);
    });
  }

  Widget buildButton(String buttonText) {
    return Expanded(
      child: TextButton(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.all(24.0),
          textStyle: const TextStyle(
            fontSize: 20,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold,
          ),
          primary: Colors.black,
          shape: const RoundedRectangleBorder(),
        ),
        onPressed: () => buttonPressed(buttonText),
        child: Text(buttonText),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(
                  vertical: 24.0,
                  horizontal: 12.0,
                ),
                child: Text(
                  _output,
                  style: const TextStyle(
                      fontSize: 48.0, fontWeight: FontWeight.bold),
                )),
            const Expanded(child: Divider()),
            Column(children: [
              Row(children: [
                buildButton('7'),
                buildButton('8'),
                buildButton('9'),
                buildButton('/')
              ]),
              Row(children: [
                buildButton('4'),
                buildButton('5'),
                buildButton('6'),
                buildButton('x')
              ]),
              Row(children: [
                buildButton('1'),
                buildButton('2'),
                buildButton('3'),
                buildButton('_')
              ]),
              Row(children: [
                buildButton('.'),
                buildButton('0'),
                buildButton('00'),
                buildButton('+')
              ]),
              Row(children: [
                buildButton('CLEAR'),
                buildButton('='),
              ]),
            ]),
          ],
        ),
      ),
    );
  }
}
