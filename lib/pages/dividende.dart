import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:number_text_input_formatter/number_text_input_formatter.dart';
import 'package:toggle_switch/toggle_switch.dart';

class DividendePage extends StatefulWidget {
  const DividendePage({super.key});

  @override
  State<DividendePage> createState() => _DividendePageState();
}

class _DividendePageState extends State<DividendePage> {
  final TextEditingController montantControllerBrut = TextEditingController();
  final TextEditingController montantControllerNet = TextEditingController();
  final TextEditingController tauxController = TextEditingController();

  double montantNet = 0;
  double montantBrut = 0;
  double montantIRVM = 0;
  bool isBrutSelected = true;
  double selectedTaux = 0.18; // Taux par défaut (18%)

  @override
  void dispose() {
    montantControllerBrut.dispose();
    montantControllerNet.dispose();
    tauxController.dispose();
    super.dispose();
  }

  /// Calcul du montant net à partir du montant brut et du taux.
  void _calculateFromBrut() {
    if (montantControllerBrut.text.isNotEmpty) {
      String cbrut = montantControllerBrut.text
          .replaceAll(RegExp(r"\s+"), "")
          .replaceAll(',', '.');
      double? brut = double.tryParse(cbrut);

      if (brut != null) {
        montantIRVM = brut * selectedTaux;
        montantNet = brut - montantIRVM;
        montantControllerNet.text = montantNet.toStringAsFixed(0);
        setState(() {});
      } else {
        _showError("Veuillez entrer un montant brut valide.");
      }
    }
  }

  /// Calcul du montant brut à partir du montant net et du taux.
  void _calculateFromNet() {
    if (montantControllerNet.text.isNotEmpty) {
      String cnet = montantControllerNet.text
          .replaceAll(RegExp(r"\s+"), "")
          .replaceAll(',', '.');
      double? net = double.tryParse(cnet);

      if (net != null) {
        montantBrut = net / (1 - selectedTaux);
        montantIRVM = montantBrut * selectedTaux;
        montantControllerBrut.text = montantBrut.toStringAsFixed(0);
        setState(() {});
      } else {
        _showError("Veuillez entrer un montant net valide.");
      }
    }
  }

  /// Gère le changement de page et effectue le calcul approprié.
  void onPageChanged(int index) {
    isBrutSelected = index == 0;
    if (isBrutSelected) {
      _calculateFromBrut();
    } else {
      _calculateFromNet();
    }
  }

  String formatValue(double value, int decimalPlaces) {
    if (value.isNaN || value.isInfinite) {
      return '0';
    }
    double roundedValue = double.parse(value.toStringAsFixed(decimalPlaces));
    return NumberFormat.decimalPattern('fr').format(roundedValue);
  }

  Widget _buildTextFieldReadonly({
    required TextEditingController controller,
    required String label,
  }) {
    return Column(
      children: [
        Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: Colors.brown,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        TextField(
          readOnly: true,
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            fillColor: Colors.brown,
            filled: true,
            labelStyle: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            floatingLabelAlignment: FloatingLabelAlignment.center,
            border: InputBorder.none,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Calcul Dividendes")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ToggleSwitch(
              activeBgColor: [Colors.brown],
              initialLabelIndex: isBrutSelected ? 0 : 1,
              labels: const ['Brut', 'Net'],
              onToggle: (index) {
                isBrutSelected = index == 0;
                onPageChanged(index!);
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller:
                  isBrutSelected ? montantControllerBrut : montantControllerNet,
              keyboardType: TextInputType.number,
              inputFormatters: [
                NumberTextInputFormatter(
                  integerDigits: 10,
                  decimalDigits: 2,
                  maxValue: '10000000000.00',
                  decimalSeparator: ',',
                  groupDigits: 3,
                  groupSeparator: ' ',
                  allowNegative: false,
                  overrideDecimalPoint: false,
                  insertDecimalPoint: false,
                  insertDecimalDigits: false,
                ),
              ],
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: isBrutSelected ? 'Dividende Brut' : 'Dividende Net',
              ),
              onChanged: (value) {
                onPageChanged(isBrutSelected ? 0 : 1);
              },
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<double>(
              value: selectedTaux,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Taux',
              ),
              items: [0.10, 0.15, 0.18, 0.20, 0.25].map((double value) {
                return DropdownMenuItem<double>(
                  value: value,
                  child: Text("${(value * 100)}%"),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedTaux = value!;
                  onPageChanged(isBrutSelected ? 0 : 1);
                });
              },
            ),
            const SizedBox(height: 20),
            _buildTextFieldReadonly(
              controller: TextEditingController(
                text: formatValue(montantIRVM, 0),
              ),
              label: 'Montant IRVM',
            ),
            const SizedBox(height: 20),
            _buildTextFieldReadonly(
              controller: TextEditingController(
                text: isBrutSelected
                    ? formatValue(montantNet, 0)
                    : formatValue(montantBrut, 0),
              ),
              label: isBrutSelected
                  ? 'Montant Dividende Net'
                  : 'Montant Dividendes Bruts',
            ),
          ],
        ),
      ),
    );
  }
}
