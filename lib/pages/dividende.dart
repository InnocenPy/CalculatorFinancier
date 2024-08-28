import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Calcul Dividendes")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ToggleSwitch(
              initialLabelIndex: isBrutSelected ? 0 : 1,
              labels: const ['Dividende Brut', 'Dividende Net'],
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
            Text("Montant IRVM: ${montantIRVM}"),
            Text(isBrutSelected
                ? "Montant Dividende Net: $montantNet"
                : "Montant Dividendes Bruts: ${montantBrut}"),
          ],
        ),
      ),
    );
  }
}
