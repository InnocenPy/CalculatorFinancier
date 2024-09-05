import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:number_text_input_formatter/number_text_input_formatter.dart';
import 'package:toggle_switch/toggle_switch.dart';

class CalculSalairePage extends StatefulWidget {
  const CalculSalairePage({super.key});

  @override
  _CalculSalairePageState createState() => _CalculSalairePageState();
}

class _CalculSalairePageState extends State<CalculSalairePage> {
  final TextEditingController salaireBrutController = TextEditingController();
  final TextEditingController avantageNatureController =
      TextEditingController();
  final TextEditingController rubriquesNonSoumisesController =
      TextEditingController();
  final TextEditingController salaireNetController = TextEditingController();

  bool isCalculFromBrut = true;

  @override
  void dispose() {
    salaireBrutController.dispose();
    avantageNatureController.dispose();
    rubriquesNonSoumisesController.dispose();
    salaireNetController.dispose();
    super.dispose();
  }

  /// Méthode générique pour obtenir une valeur numérique depuis un contrôleur.
  double _parseInputValue(TextEditingController controller,
      {double fallback = 0}) {
    String cleanedValue =
        controller.text.replaceAll(RegExp(r"\s+"), "").replaceAll(',', '.');
    return double.tryParse(cleanedValue) ?? fallback;
  }

  String formatValue(double value, int fractionDigits) {
    return NumberFormat.currency(
      locale: 'fr_FR',
      symbol: '',
      decimalDigits: fractionDigits,
    ).format(value);
  }

  void _calculateFromBrut() {
    if (salaireBrutController.text.isNotEmpty &&
        avantageNatureController.text.isNotEmpty &&
        rubriquesNonSoumisesController.text.isNotEmpty) {
      double B3 = _parseInputValue(salaireBrutController);
      double B4 = _parseInputValue(avantageNatureController);
      double B5 = _parseInputValue(rubriquesNonSoumisesController);

      // Vérifications de sécurité pour éviter des erreurs de calcul
      if (B3 <= 0 || B4 < 0 || B5 < 0) {
        return; // Stop si les valeurs ne sont pas valides
      }

      double net = B3 - ((B3 - B5) * 0.0666) - B4;
      // salaireNetController.text = net.toStringAsFixed(2);
      salaireNetController.text = formatValue(net, 2);
    }
  }

  void _calculateFromNet() {
    if (salaireNetController.text.isNotEmpty &&
        avantageNatureController.text.isNotEmpty &&
        rubriquesNonSoumisesController.text.isNotEmpty) {
      double B10 = _parseInputValue(salaireNetController);
      double B11 = _parseInputValue(avantageNatureController);
      double B12 = _parseInputValue(rubriquesNonSoumisesController);

      // Vérifications de sécurité pour éviter des erreurs de calcul
      if (B10 <= 0 || B11 < 0 || B12 < 0) {
        return; // Stop si les valeurs ne sont pas valides
      }

      double brut = (B10 + B11 + (-B12 * 0.0666)) / 0.9334;
      // salaireBrutController.text = brut.toStringAsFixed(2);
      salaireBrutController.text = formatValue(brut, 2);
    }
  }

  void _onToggleSwitch(int index) {
    setState(() {
      isCalculFromBrut = index == 0;
      if (isCalculFromBrut) {
        _calculateFromBrut();
      } else {
        _calculateFromNet();
      }
    });
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required Function(String) onChanged,
  }) {
    return TextField(
      controller: controller,
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
        labelText: label,
      ),
      onChanged: onChanged,
    );
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
              color: Colors.brown, // Définit la couleur du texte
            ),
            textAlign: TextAlign.center, // Centre le texte horizontalement
          ),
        ),
        TextField(
          readOnly: true, // Champ en lecture seule
          controller: controller,
          style:
              const TextStyle(color: Colors.white), // Couleur du texte en blanc
          decoration: const InputDecoration(
            fillColor: Colors.brown, // Couleur de fond marron
            filled: true, // Activer le remplissage de la couleur de fond
            labelStyle: TextStyle(
              color: Colors.white, // Couleur du texte du label en blanc
              fontSize: 16, // Taille du texte du label
            ),
            floatingLabelAlignment: FloatingLabelAlignment.center,

            border: InputBorder.none, // Pas de bordure
            //labelText: label,
            alignLabelWithHint:
                true, // Pour aligner le label avec le hint et centrer
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Calcul Salaires Brut/Net")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ToggleSwitch(
              initialLabelIndex: isCalculFromBrut ? 0 : 1,
              labels: ['Brut', 'Net'],
              activeBgColor: [Colors.brown],
              onToggle: (index) {
                _onToggleSwitch(index!);
              },
            ),
            const SizedBox(height: 20),
            if (isCalculFromBrut) ...[
              _buildTextField(
                controller: salaireBrutController,
                label: 'Salaire Brut',
                onChanged: (value) {
                  _calculateFromBrut();
                  setState(() {}); // Update state after calculation
                },
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: avantageNatureController,
                label: 'Avantage en Nature',
                onChanged: (value) {
                  _calculateFromBrut();
                  setState(() {}); // Update state after calculation
                },
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: rubriquesNonSoumisesController,
                label: 'Rubriques Non Soumises',
                onChanged: (value) {
                  _calculateFromBrut();
                  setState(() {}); // Update state after calculation
                },
              ),
              const SizedBox(height: 40),
              _buildTextFieldReadonly(
                  controller: salaireNetController,
                  label: 'Salaire Net (avant prélèvement de ITS)'),
            ] else ...[
              _buildTextField(
                controller: salaireNetController,
                label: 'Salaire Net',
                onChanged: (value) {
                  _calculateFromNet();
                  setState(() {}); // Update state after calculation
                },
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: avantageNatureController,
                label: 'Avantage en Nature',
                onChanged: (value) {
                  _calculateFromNet();
                  setState(() {}); // Update state after calculation
                },
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: rubriquesNonSoumisesController,
                label: 'Rubriques Non Soumises',
                onChanged: (value) {
                  _calculateFromNet();
                  setState(() {}); // Update state after calculation
                },
              ),
              const SizedBox(height: 40),
              _buildTextFieldReadonly(
                  controller: salaireBrutController, label: 'Salaire Brut')
            ],
          ],
        ),
      ),
    );
  }
}
