import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    double brut = double.tryParse(montantControllerBrut.text) ?? 0;
    montantIRVM =
        brut * selectedTaux; // Montant IRVM = Dividende Brut * Taux IRVM
    montantNet = brut -
        montantIRVM; // Montant Dividende Net = Dividende Brut - Montant IRVM

    montantControllerNet.text = montantNet.toStringAsFixed(0);

    setState(() {});
  }

  /// Calcul du montant brut à partir du montant net et du taux.
  void _calculateFromNet() {
    double net = double.tryParse(montantControllerNet.text) ?? 0;
    montantBrut = net /
        (1 -
            selectedTaux); // Montant Dividendes Bruts = Dividende Net / (100% - Taux IRVM)
    montantIRVM = montantBrut *
        selectedTaux; // Montant IRVM = (Dividende Net / (100% - Taux IRVM)) * Taux IRVM

    montantControllerBrut.text = montantBrut.toStringAsFixed(0);

    setState(() {});
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
    // Vérifier si la valeur est NaN (Not a Number) ou infinie
    if (value.isNaN || value.isInfinite) {
      return '0';
    }

    // Arrondir la valeur au nombre de décimales spécifié
    double roundedValue = double.parse(value.toStringAsFixed(decimalPlaces));

    // Formater la valeur arrondie avec le séparateur de milliers
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
                controller:
                    TextEditingController(text: formatValue(montantIRVM, 0)),
                label: 'Montant IRVM'),
            // Text("Montant IRVM: ${montantIRVM} "),
            // _buildTextFieldReadonly(
            //     controller: TextEditingController(
            //       text: formatValue(montantNet, 0),
            //     ),
            //     label: 'Montant Dividende Net'),
            // Text(isBrutSelected
            //     ? "Montant Dividende Net: $montantNet"
            //     : "Montant Dividendes Bruts: ${montantBrut}"),
            // _buildTextFieldReadonly(
            //     controller: montantControllerBrut,
            //     label: 'Montant Dividendes Bruts'),
            _buildTextFieldReadonly(
                controller: isBrutSelected
                    ? TextEditingController(
                        text: formatValue(montantNet, 0),
                      )
                    : TextEditingController(
                        text: formatValue(montantBrut, 0),
                      ),
                label: isBrutSelected
                    ? 'Montant Dividende Net'
                    : 'Montant Dividendes Bruts')
          ],
        ),
      ),
    );
  }
}
