import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:toggle_switch/toggle_switch.dart';

class TauxDeMargePage extends StatefulWidget {
  const TauxDeMargePage({super.key});

  @override
  State<TauxDeMargePage> createState() => _TauxDeMargePageState();
}

class _TauxDeMargePageState extends State<TauxDeMargePage> {
  final TextEditingController prixAchatController = TextEditingController();
  final TextEditingController tauxMargeController = TextEditingController();
  final TextEditingController prixVenteTTCController = TextEditingController();
  final TextEditingController coefficientController = TextEditingController();
  final TextEditingController tauxTVAController = TextEditingController();

  double prixAchatHT = 0;
  double prixVenteHT = 0;
  double prixVenteTTC = 0;
  double marge = 0;
  double coefficient = 0;
  double tauxMarge = 0;

  bool isTauxMargeSelected = true;
  bool isPrixVenteSelected = false;
  bool isCoefficientSelected = false;

  @override
  void dispose() {
    prixAchatController.dispose();
    tauxMargeController.dispose();
    prixVenteTTCController.dispose();
    coefficientController.dispose();
    tauxTVAController.dispose();
    super.dispose();
  }

  /// Calcul à partir du taux de marge.
  void _calculateFromTauxMarge() {
    double prixAchat = double.tryParse(prixAchatController.text) ?? 0;
    double tauxMarge = (double.tryParse(tauxMargeController.text) ?? 0) / 100;
    double tauxTVA = (double.tryParse(tauxTVAController.text) ?? 0) / 100;

    // Calcul des valeurs de base
    prixVenteHT = prixAchat / (1 - tauxMarge);
    prixVenteTTC = prixVenteHT * (1 + tauxTVA);
    marge = prixVenteHT - prixAchat;
    coefficient = prixVenteTTC / prixAchat;

    prixVenteTTCController.text = formatValue(prixVenteTTC, 0);

    // Mise à jour des autres valeurs interconnectées
    setState(() {
      this.prixVenteHT = prixVenteHT;
      this.prixVenteTTC = prixVenteTTC;
      this.marge = marge;
      this.coefficient = coefficient;
      this.tauxMarge = tauxMarge * 100; // Conversion en pourcentage
    });
  }

  void _calculateFromPrixVenteTTC() {
    double prixAchat = double.tryParse(prixAchatController.text) ?? 0;
    double prixVenteTTC = double.tryParse(prixVenteTTCController.text) ?? 0;
    double tauxTVA = (double.tryParse(tauxTVAController.text) ?? 0) / 100;

    // Calcul des valeurs de base
    prixVenteHT = prixVenteTTC / (1 + tauxTVA);
    marge = prixVenteHT - prixAchat;
    coefficient = prixVenteTTC / prixAchat;
    tauxMarge = (marge / prixVenteHT) * 100;

    tauxMargeController.text = formatValue(tauxMarge, 0);

    coefficientController.text = formatValue(coefficient, 1);

    // Mise à jour des autres valeurs interconnectées
    setState(() {
      this.prixVenteTTC = prixVenteTTC;
      this.prixVenteHT = prixVenteHT;
      this.marge = marge;
      this.coefficient = coefficient;
      this.tauxMarge = tauxMarge;
    });
  }

  void _calculateFromCoefficient() {
    double prixAchat = double.tryParse(prixAchatController.text) ?? 0;
    double coefficient = double.tryParse(coefficientController.text) ?? 0;
    double tauxTVA = (double.tryParse(tauxTVAController.text) ?? 0) / 100;

    // Calcul des valeurs de base
    prixVenteHT = prixAchat * coefficient / (1 + tauxTVA);
    prixVenteTTC = prixAchat * coefficient;
    marge = prixVenteHT - prixAchat;
    tauxMarge = (marge / prixVenteHT) * 100;

    prixVenteTTCController.text = formatValue(prixVenteTTC, 0);
    tauxMargeController.text = formatValue(tauxMarge, 0);

    // Mise à jour des autres valeurs interconnectées
    setState(() {
      this.prixVenteHT = prixVenteHT;
      this.prixVenteTTC = prixVenteTTC;
      this.marge = marge;
      this.coefficient = coefficient;
      this.tauxMarge = tauxMarge;
    });
  }

  String formatValue(double value, int decimalPlaces) {
    return value.isNaN || value.isInfinite
        ? '0'
        : value.toStringAsFixed(decimalPlaces);
  }

  /// Gère le changement de page et effectue le calcul approprié.
  void onPageChanged(int index) {
    isTauxMargeSelected = index == 0;
    isPrixVenteSelected = index == 1;
    isCoefficientSelected = index == 2;

    if (isTauxMargeSelected) {
      _calculateFromTauxMarge();
    } else if (isPrixVenteSelected) {
      _calculateFromPrixVenteTTC();
    } else if (isCoefficientSelected) {
      _calculateFromCoefficient();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Calcul Taux de Marge")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ToggleSwitch(
              initialLabelIndex: isTauxMargeSelected
                  ? 0
                  : isPrixVenteSelected
                      ? 1
                      : 2,
              labels: const ['Taux de Marge', 'Prix de Vente', 'Coefficient'],
              onToggle: (index) {
                onPageChanged(index!);
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: prixAchatController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Prix d\'achat HT',
              ),
              onChanged: (value) {
                onPageChanged(isTauxMargeSelected
                    ? 0
                    : isPrixVenteSelected
                        ? 1
                        : 2);
              },
            ),
            const SizedBox(height: 20),
            if (isTauxMargeSelected)
              TextField(
                controller: tauxMargeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Taux de Marge (%)',
                ),
                onChanged: (value) {
                  _calculateFromTauxMarge();
                },
              ),
            if (isPrixVenteSelected)
              TextField(
                controller: prixVenteTTCController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Prix de Vente TTC',
                ),
                onChanged: (value) {
                  _calculateFromPrixVenteTTC();
                },
              ),
            if (isCoefficientSelected)
              TextField(
                controller: coefficientController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Coefficient',
                ),
                onChanged: (value) {
                  _calculateFromCoefficient();
                },
              ),
            const SizedBox(height: 20),
            TextField(
              controller: tauxTVAController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Taux de TVA (%)',
              ),
              onChanged: (value) {
                onPageChanged(isTauxMargeSelected
                    ? 0
                    : isPrixVenteSelected
                        ? 1
                        : 2);
              },
            ),
            SizedBox(height: 20),
            _InfoLine("Prix de Vente HT:", prixVenteHT),
            _InfoLine("Prix de Vente TTC:", prixVenteTTC),
            _InfoLine("Marge:", marge),
            _InfoLine("Coefficient:", coefficient),
            _InfoLine("Taux de Marge:", tauxMarge),
          ],
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final String label;
  final dynamic value;

  _InfoLine(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: TextStyle(fontSize: 16)),
        Text(
          value is num
              ? NumberFormat.decimalPattern('fr').format(value)
              : value.toString(),
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
