import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(ApostaEsportivaApp());
}

class ApostaEsportivaApp extends StatelessWidget {
  const ApostaEsportivaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aposta Esportiva',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CalculadoraPage(),
    );
  }
}

class CalculadoraPage extends StatefulWidget {
  const CalculadoraPage({super.key});

  @override
  _CalculadoraPageState createState() => _CalculadoraPageState();
}

class _CalculadoraPageState extends State<CalculadoraPage> {
  final TextEditingController _stakeController = TextEditingController();
  final TextEditingController _targetController = TextEditingController();
  final TextEditingController _percentageController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  DateTime? _selectedDate;
  String _result = '';
  String _selectedCalculation = 'Valor Alvo';

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = '${_selectedDate!.toLocal()}'.split(' ')[0];
      });
    }
  }

  void _calcular() {
    final double stakeInicial = double.tryParse(_stakeController.text) ?? 0;
    final int numeroDias = _selectedDate?.difference(DateTime.now()).inDays ?? 0;

    if (stakeInicial > 0 && numeroDias > 0) {
      if (_selectedCalculation == 'Valor Alvo') {
        final double valorAlvo = double.tryParse(_targetController.text) ?? 0;
        if (valorAlvo > 0) {
          final double taxaDiaria = pow(valorAlvo / stakeInicial, 1 / numeroDias) - 1;
          final double porcentagemDiaria = taxaDiaria * 100;
          setState(() {
            _result = 'Você precisa de ${porcentagemDiaria.toStringAsFixed(2)}% ao dia.';
          });
        } else {
          setState(() {
            _result = 'Por favor, insira um valor alvo válido.';
          });
        }
      } else if (_selectedCalculation == 'Porcentagem Diária') {
        final double porcentagemDiaria = double.tryParse(_percentageController.text) ?? 0;
        if (porcentagemDiaria > 0) {
          final double taxaDiaria = porcentagemDiaria / 100;
          final double valorFinal = stakeInicial * pow(1 + taxaDiaria, numeroDias);
          setState(() {
            _result = 'Você terá R\$${valorFinal.toStringAsFixed(2)} no final.';
          });
        } else {
          setState(() {
            _result = 'Por favor, insira uma porcentagem diária válida.';
          });
        }
      }
    } else {
      setState(() {
        _result = 'Por favor, insira valores válidos e selecione uma data.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculadora de Aposta'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _stakeController,
              decoration: const InputDecoration(labelText: 'Stake Inicial (R\$)'),
              keyboardType: TextInputType.number,
            ),
            DropdownButton<String>(
              value: _selectedCalculation,
              items: <String>['Valor Alvo', 'Porcentagem Diária']
                  .map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCalculation = newValue!;
                  _result = '';
                });
              },
            ),
            if (_selectedCalculation == 'Valor Alvo')
              TextField(
                controller: _targetController,
                decoration: const InputDecoration(labelText: 'Valor Alvo (R\$)'),
                keyboardType: TextInputType.number,
              ),
            if (_selectedCalculation == 'Porcentagem Diária')
              TextField(
                controller: _percentageController,
                decoration: const InputDecoration(labelText: 'Porcentagem Diária (%)'),
                keyboardType: TextInputType.number,
              ),
            TextFormField(
              controller: _dateController,
              decoration: const InputDecoration(labelText: 'Data Final'),
              readOnly: true,
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _calcular,
              child: const Text('Calcular'),
            ),
            const SizedBox(height: 20),
            Text(
              _result,
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
