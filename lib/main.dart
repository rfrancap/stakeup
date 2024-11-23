import 'package:flutter/material.dart';
import 'dart:math';
import 'package:singular_flutter_sdk/singular.dart';
import 'package:singular_flutter_sdk/singular_config.dart';


void main() {
  runApp(const ApostaEsportivaApp());
SingularConfig config = new SingularConfig('viperace_4e5d96af', '215bca3ffef58ad26b931adc0cc8bcca');
Singular.start(config);
  
}

class ApostaEsportivaApp extends StatelessWidget {
  const ApostaEsportivaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bet Booster',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Colors.grey[900],
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 18.0, fontFamily: 'Roboto', color: Colors.white),
        ),
      ),
      home: const CalculadoraPage(),
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
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.orange,
              onPrimary: Colors.white,
              surface: Colors.grey,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: Colors.grey[900],
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = '${_selectedDate!.toLocal()}'.split(' ')[0];
      });
    }
  }

  void _calcular() {
    Singular.event('new_calculation');
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
        title: const Text('Bet Booster', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.grey[900]!, Colors.grey[800]!],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    spreadRadius: 5,
                    blurRadius: 15,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTextField(_stakeController, 'Stake Inicial (R\$)'),
                  const SizedBox(height: 16),
                  _buildDropdownButton(),
                  const SizedBox(height: 16),
                  if (_selectedCalculation == 'Valor Alvo')
                    _buildTextField(_targetController, 'Valor Alvo (R\$)')
                  else
                    _buildTextField(_percentageController, 'Porcentagem Diária (%)'),
                  const SizedBox(height: 16),
                  _buildDateField(),
                  const SizedBox(height: 24),
                  _buildCalculateButton(),
                  const SizedBox(height: 20),
                  _buildResultText(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.orange[300]),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.orange[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.orange),
        ),
      ),
      style: const TextStyle(color: Colors.white),
      keyboardType: TextInputType.number,
    );
  }

  Widget _buildDropdownButton() {
    return DropdownButtonFormField<String>(
      value: _selectedCalculation,
      items: <String>['Valor Alvo', 'Porcentagem Diária'].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, style: const TextStyle(color: Colors.white)),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedCalculation = newValue!;
          _result = '';
        });
      },
      dropdownColor: Colors.grey[850],
      decoration: InputDecoration(
        labelText: 'Tipo de Cálculo',
        labelStyle: TextStyle(color: Colors.orange[300]),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.orange[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.orange),
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return TextFormField(
      controller: _dateController,
      decoration: InputDecoration(
        labelText: 'Data Final',
        labelStyle: TextStyle(color: Colors.orange[300]),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.orange[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.orange),
        ),
        suffixIcon: Icon(Icons.calendar_today, color: Colors.orange[300]),
      ),
      style: const TextStyle(color: Colors.white),
      readOnly: true,
      onTap: () => _selectDate(context),
    );
  }

  Widget _buildCalculateButton() {
    return ElevatedButton(
      onPressed: _calcular,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: const Text('Calcular', style: TextStyle(fontSize: 18, color: Colors.white)),
    );
  }

  Widget _buildResultText() {
    return Text(
      _result,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange),
      textAlign: TextAlign.center,
    );
  }
}