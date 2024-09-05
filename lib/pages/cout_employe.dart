import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:number_text_input_formatter/number_text_input_formatter.dart';
import 'package:toggle_switch/toggle_switch.dart';

class CoutEmployeurPage extends StatefulWidget {
  @override
  _CoutEmployeurPageState createState() => _CoutEmployeurPageState();
}

class _CoutEmployeurPageState extends State<CoutEmployeurPage> {
  int _selectedToggleIndex = 0;

  // Controllers for input fields
  final TextEditingController salaireBrutController = TextEditingController();
  final TextEditingController rubriquesNonSoumisesController =
      TextEditingController();
  final TextEditingController salaireNetController = TextEditingController();
  final TextEditingController coutEmployeurController = TextEditingController();
  final TextEditingController avantageNatureController =
      TextEditingController();
  final TextEditingController salaireBrutReadonlyController =
      TextEditingController();

  // Dropdown values for taux
  double? tauxAccidentTravail;
  double? tauxAccidentTravailNet;
  double? tauxAccidentTravailCout;

  String resultatCoutEmployeur = '';
  String resultatSalaireBrut = '';
  String resultatSalaireNet = '';

  @override
  void dispose() {
    salaireBrutController.dispose();
    rubriquesNonSoumisesController.dispose();
    salaireNetController.dispose();
    coutEmployeurController.dispose();
    avantageNatureController.dispose();
    super.dispose();
  }

  /// Méthode générique pour obtenir une valeur numérique depuis un contrôleur.
  double _parseInputValue(TextEditingController controller,
      {double fallback = 0}) {
    String cleanedValue =
        controller.text.replaceAll(RegExp(r"\s+"), "").replaceAll(',', '.');
    return double.tryParse(cleanedValue) ?? fallback;
  }

  /// Pour formater la valeur avec des espaces
  String formatValue(double value, int fractionDigits) {
    return NumberFormat.currency(
      locale: 'fr_FR',
      symbol: '',
      decimalDigits: fractionDigits,
    ).format(value);
  }

// Function to calculate "Coût Employeur" from "Salaire Brut"
  void _calculateCoutEmployeurFromBrut() {
    double B3 = _parseInputValue(salaireBrutController);
    double B5 = _parseInputValue(rubriquesNonSoumisesController);
    double B4 = tauxAccidentTravail ?? 0;

    if (B3 <= 0 || B5 < 0 || B4 < 0) {
      return; // Vérifications de sécurité
    }

    double coutEmployeur = B3 + ((B3 - B5) * (0.179 + B4)) + (B3 * 0.045);
    setState(() {
      resultatCoutEmployeur = formatValue(coutEmployeur, 2);
    });
  }

// Function to calculate "Coût Employeur" from "Salaire Net" and update "Salaire Brut"
  void _calculateCoutEmployeurFromNet() {
    double B12 = _parseInputValue(salaireNetController);
    double B11 = _parseInputValue(rubriquesNonSoumisesController);
    double B10 = _parseInputValue(avantageNatureController);
    double B13 = tauxAccidentTravailNet ?? 0;

    if (B12 <= 0 || B11 < 0 || B10 < 0 || B13 < 0) {
      return; // Vérifications de sécurité
    }

    // Calculate Salaire Brut
    double salaireBrut = (B12 + B10 + (-B11 * 0.0666)) / 0.9334;
    salaireBrutReadonlyController.text = salaireBrut.toStringAsFixed(2);

    // Calculate Coût Employeur
    double coutEmployeur =
        B12 + B10 + ((B12 - B11) * (0.179 + B13)) + (B12 * 0.045);
    setState(() {
      resultatCoutEmployeur = coutEmployeur.toStringAsFixed(2);
    });
  }

// Function to calculate "Salaire Brut" and "Salaire Net" from "Coût Employeur"
  void _calculateSalaireFromCoutEmployeur() {
    double B17 = _parseInputValue(coutEmployeurController);
    double B19 = _parseInputValue(rubriquesNonSoumisesController);
    double B20 = _parseInputValue(avantageNatureController);
    double B18 = tauxAccidentTravailCout ?? 0;

    if (B17 <= 0 || B19 < 0 || B20 < 0 || B18 < 0) {
      return; // Vérifications de sécurité
    }

    double salaireBrut =
        (B17 + ((0.179 + B18) * B19)) / (1 + (0.179 + B18) + 0.045);
    double salaireNet = salaireBrut - (((salaireBrut - B19) * 0.0666)) - B20;

    setState(() {
      resultatSalaireBrut = salaireBrut.toStringAsFixed(2);
      resultatSalaireNet = salaireNet.toStringAsFixed(2);
    });
  }

  void _onToggleSwitch(int index) {
    setState(() {
      _selectedToggleIndex = index;
    });
  }

  // Pour les input numerique
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
        border: OutlineInputBorder(),
        labelText: label,
      ),
      onChanged: onChanged,
    );
  }

  // Pour les input en lecture unique
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

  Widget _buildDropdown({
    required String label,
    required double? value,
    required List<double> items,
    required ValueChanged<double?> onChanged,
  }) {
    return DropdownButtonFormField<double>(
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: label,
      ),
      value: value,
      items: items
          .map((item) => DropdownMenuItem(
                value: item,
                child: Text('${(item * 100).toStringAsFixed(2)}%'),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Calcul salaire / Coût employeur")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ToggleSwitch(
              customWidths: [100, 100, 300], // Largeurs pour chaque label
              activeBgColor: [Colors.brown],
              initialLabelIndex: _selectedToggleIndex,
              labels: const ['Brut', 'Net', 'Coût Employeur'],
              onToggle: (index) {
                _onToggleSwitch(index!);
              },
            ),
            const SizedBox(height: 20),
            if (_selectedToggleIndex == 0) ...[
              _buildTextField(
                controller: salaireBrutController,
                label: 'Salaire Brut',
                onChanged: (value) => _calculateCoutEmployeurFromBrut(),
              ),
              const SizedBox(height: 20),
              _buildDropdown(
                label: 'Taux Accident du Travail',
                value: tauxAccidentTravail,
                items: [
                  0.01,
                  0.02,
                  0.03,
                  0.04
                ], // Example rates: 1%, 2%, 3%, 4%
                onChanged: (value) {
                  tauxAccidentTravail = value;
                  _calculateCoutEmployeurFromBrut();
                },
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: rubriquesNonSoumisesController,
                label: 'Rubriques Non Soumises',
                onChanged: (value) => _calculateCoutEmployeurFromBrut(),
              ),
              const SizedBox(height: 40),
              _buildTextFieldReadonly(
                  controller:
                      TextEditingController(text: resultatCoutEmployeur),
                  label: 'Coût Employeur (CF et TL inclus)')
            ] else if (_selectedToggleIndex == 1) ...[
              _buildTextField(
                controller: salaireNetController,
                label: 'Salaire Net',
                onChanged: (value) => _calculateCoutEmployeurFromNet(),
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: avantageNatureController,
                label: 'Avantage en Nature',
                onChanged: (value) => _calculateCoutEmployeurFromNet(),
              ),
              const SizedBox(height: 20),
              _buildDropdown(
                label: 'Taux Accident du Travail',
                value: tauxAccidentTravailNet,
                items: [
                  0.01,
                  0.02,
                  0.03,
                  0.04
                ], // Example rates: 1%, 2%, 3%, 4%
                onChanged: (value) {
                  tauxAccidentTravailNet = value;
                  _calculateCoutEmployeurFromNet();
                },
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: rubriquesNonSoumisesController,
                label: 'Rubriques Non Soumises',
                onChanged: (value) => _calculateCoutEmployeurFromNet(),
              ),
              const SizedBox(height: 40),
              TextField(
                enabled: false,
                controller: salaireBrutReadonlyController,
                keyboardType: const TextInputType.numberWithOptions(),
                decoration: const InputDecoration(
                    fillColor: Colors.brown,
                    filled: true,
                    border: OutlineInputBorder(),
                    hintText: 'Salaire Brut',
                    hintStyle: TextStyle(color: Colors.white, fontSize: 18)),
                onChanged: null,
              ),
              // _buildTextField(
              //   controller: salaireBrutReadonlyController,
              //   label: 'Salaire Brut',
              //   onChanged:  // Readonly field, no onChanged needed
              // ),
              const SizedBox(height: 20),

              _buildTextFieldReadonly(
                  controller:
                      TextEditingController(text: resultatCoutEmployeur),
                  label: 'Coût Employeur (CF et TL inclus)'),
            ] else if (_selectedToggleIndex == 2) ...[
              _buildTextField(
                controller: coutEmployeurController,
                label: 'Coût Employeur',
                onChanged: (value) => _calculateSalaireFromCoutEmployeur(),
              ),
              const SizedBox(height: 20),
              _buildDropdown(
                label: 'Taux Accident du Travail',
                value: tauxAccidentTravailCout,
                items: [
                  0.01,
                  0.02,
                  0.03,
                  0.04
                ], // Example rates: 1%, 2%, 3%, 4%
                onChanged: (value) {
                  tauxAccidentTravailCout = value;
                  _calculateSalaireFromCoutEmployeur();
                },
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: rubriquesNonSoumisesController,
                label: 'Rubriques Non Soumises',
                onChanged: (value) => _calculateSalaireFromCoutEmployeur(),
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: avantageNatureController,
                label: 'Avantage en Nature',
                onChanged: (value) => _calculateSalaireFromCoutEmployeur(),
              ),
              const SizedBox(height: 40),
              _buildTextFieldReadonly(
                  controller: TextEditingController(text: resultatSalaireBrut),
                  label: 'Salaire Brut'),
              const SizedBox(height: 10),
              _buildTextFieldReadonly(
                  controller: TextEditingController(text: resultatSalaireNet),
                  label: 'Salaire Net')
            ],
          ],
        ),
      ),
    );
  }
}
