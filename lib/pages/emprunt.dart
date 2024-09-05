import 'package:flutter/material.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:number_text_input_formatter/number_text_input_formatter.dart';

class SimulationEmpruntPage extends StatefulWidget {
  @override
  _SimulationEmpruntPageState createState() => _SimulationEmpruntPageState();
}

class _SimulationEmpruntPageState extends State<SimulationEmpruntPage> {
  TextEditingController montantEmprunteController = TextEditingController();
  TextEditingController tauxAnnuelController = TextEditingController();

  int dureeEmprunt = 1; // en années
  int paiementsParAn = 12;

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

  @override
  Widget build(BuildContext context) {
    double montantEmprunte = _parseInputValue(montantEmprunteController);
    double tauxAnnuel = _parseInputValue(tauxAnnuelController) / 100;

    int nombreEcheances = dureeEmprunt * paiementsParAn;
    double tauxParPeriode = tauxAnnuel / paiementsParAn;
    double remboursementParEcheance = montantEmprunte *
        (tauxParPeriode / (1 - pow(1 / (1 + tauxParPeriode), nombreEcheances)));

    remboursementParEcheance =
        remboursementParEcheance.isNaN ? 0 : remboursementParEcheance;

    double interetsTotaux =
        (remboursementParEcheance * nombreEcheances) - montantEmprunte;
    interetsTotaux = interetsTotaux.isNaN ? 0 : interetsTotaux;

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Champ de saisie pour le montant du prêt
              TextField(
                controller: montantEmprunteController,
                cursorColor: Colors.blue,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Montant emprunte',
                ),
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
                onChanged: (value) {
                  setState(() {});
                },
              ),

              SizedBox(height: 20),

              // Champ de saisie pour le taux annuel
              TextField(
                controller: tauxAnnuelController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Taux (%)',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {});
                },
              ),

              const SizedBox(height: 40),

              // Durée de l'emprunt
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      const Text('Durée de l\'emprunt (années) :'),
                      const SizedBox(width: 20),
                      IconButton(
                          color: Colors.brown,
                          focusColor: Colors.blue,
                          onPressed: () {
                            if (dureeEmprunt > 1) {
                              setState(() {
                                dureeEmprunt--;
                              });
                            }
                          },
                          icon: Icon(Icons.exposure)),
                      const SizedBox(width: 10),
                      Text(' $dureeEmprunt ${dureeEmprunt > 1 ? 'an' : ''}',
                          style: const TextStyle(
                              color: Colors.brown,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(width: 10),
                      IconButton(
                          color: Colors.brown,
                          focusColor: Colors.red,
                          onPressed: () {
                            setState(() {
                              dureeEmprunt++;
                            });
                          },
                          icon: const Icon(Icons.add_circle_outline_outlined)),
                      const SizedBox(width: 10),
                    ],
                  ),
                ],
              ),

              // Nombre de paiements par an
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text('Nombre de paiements par an : '),
                  const SizedBox(width: 20),
                  IconButton(
                      color: Colors.brown,
                      focusColor: Colors.blue,
                      onPressed: () {
                        if (paiementsParAn > 1) {
                          setState(() {
                            paiementsParAn--;
                          });
                        }
                      },
                      icon: Icon(Icons.exposure)),
                  const SizedBox(width: 10),
                  Text('$paiementsParAn'),
                  const SizedBox(width: 10),
                  IconButton(
                      color: Colors.brown,
                      focusColor: Colors.blue,
                      onPressed: () {
                        setState(() {
                          paiementsParAn++;
                        });
                      },
                      icon: Icon(Icons.add_circle)),
                  const SizedBox(width: 10),
                ],
              ),

              // Section des résultats
              SizedBox(height: 20),
              Text('Nombre d\'échéances : $nombreEcheances'),
              Text(
                  'Remboursement par échéance : ${formatValue(remboursementParEcheance, 2)}'),
              Text('Intérêts totaux : ${formatValue(interetsTotaux, 2)}'),

              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
