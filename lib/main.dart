
import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatriceApp());
}

class CalculatriceApp extends StatelessWidget {
  const CalculatriceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CalculatricePage(),
    );
  }
}

class CalculatricePage extends StatefulWidget {
  const CalculatricePage({super.key});

  @override
  State<CalculatricePage> createState() => _CalculatricePageState();
}

class _CalculatricePageState extends State<CalculatricePage> {
  String affichage = '0';
  String operation = '';

  double? premierNombre;
  String? operateur;
  bool nouveauNombre = true;

  // Convertit un nombre en texte sans zeros decimaux inutiles.
  String formater(double nombre) {
    if (!nombre.isFinite) return 'Erreur';

    if (nombre == nombre.truncateToDouble()) {
      return nombre.toInt().toString();
    }

    return nombre.toString();
  }

  // Ajoute un chiffre ou un point decimal.
  void ajouterChiffre(String chiffre) {
    setState(() {
      if (affichage == 'Erreur' || nouveauNombre) {
        affichage = chiffre == '.' ? '0.' : chiffre;
        nouveauNombre = false;
      } else if (chiffre == '.' && affichage.contains('.')) {
        return;
      } else if (affichage.length < 15) {
        affichage += chiffre;
      }
    });
  }

  // Effectue une operation mathematique.
  double calculer(double a, double b, String op) {
    switch (op) {
      case '+':
        return a + b;
      case '-':
        return a - b;
      case '×':
        return a * b;
      case '÷':
        if (b == 0) throw Exception('Division par zero');
        return a / b;
      case '%':
        if (b == 0) throw Exception('Modulo par zero');
        return a % b;
      default:
        return b;
    }
  }

  // Enregistre l'operateur choisi.
  void choisirOperateur(String op) {
    setState(() {
      if (affichage == 'Erreur') return;

      if (premierNombre != null &&
          operateur != null &&
          !nouveauNombre) {
        try {
          affichage = formater(
            calculer(premierNombre!, double.parse(affichage), operateur!),
          );
        } catch (_) {
          reinitialiser();
          affichage = 'Erreur';
          return;
        }
      }

      premierNombre = double.parse(affichage);
      operateur = op;
      operation = '${formater(premierNombre!)} $op';
      nouveauNombre = true;
    });
  }

  // Affiche le resultat final.
  void resultat() {
    if (premierNombre == null || operateur == null) return;

    setState(() {
      try {
        final secondNombre = double.parse(affichage);
        final resultat = calculer(
          premierNombre!,
          secondNombre,
          operateur!,
        );

        operation =
            '${formater(premierNombre!)} $operateur '
            '${formater(secondNombre)} =';

        affichage = formater(resultat);
        premierNombre = null;
        operateur = null;
        nouveauNombre = true;
      } catch (_) {
        affichage = 'Erreur';
        operation = 'Operation impossible';
        premierNombre = null;
        operateur = null;
        nouveauNombre = true;
      }
    });
  }

  // Inverse le signe du nombre affiche.
  void changerSigne() {
    setState(() {
      if (affichage == 'Erreur' || affichage == '0') return;

      affichage = affichage.startsWith('-')
          ? affichage.substring(1)
          : '-$affichage';
    });
  }

  // Reinitialise la calculatrice.
  void reinitialiser() {
    affichage = '0';
    operation = '';
    premierNombre = null;
    operateur = null;
    nouveauNombre = true;
  }

  // Cree un bouton du clavier.
  Widget bouton(
    String texte, {
    Color couleur = const Color(0xFF333333),
    VoidCallback? action,
    bool grand = false,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: SizedBox.expand(
          child: ElevatedButton(
            onPressed: action,
            style: ElevatedButton.styleFrom(
              backgroundColor: couleur,
              foregroundColor: Colors.white,
              shape: grand
                  ? const StadiumBorder()
                  : const CircleBorder(),
              padding: EdgeInsets.zero,
              elevation: 0,
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                texte,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget ligne(List<Widget> boutons) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: boutons,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFFF9800);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Zone d'affichage.
            Expanded(
              flex: 4,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 20,
                ),
                alignment: Alignment.bottomRight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      operation,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 22,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 18),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        affichage,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 52,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Clavier numerique.
            Expanded(
              flex: 6,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 15),
                child: Column(
                  children: [
                    ligne([
                      bouton('C', action: () {
                        setState(reinitialiser);
                      }),
                      bouton('%', action: () => choisirOperateur('%')),
                      bouton('÷', couleur: orange,
                          action: () => choisirOperateur('÷')),
                      bouton('×', couleur: orange,
                          action: () => choisirOperateur('×')),
                    ]),
                    ligne([
                      bouton('7', action: () => ajouterChiffre('7')),
                      bouton('8', action: () => ajouterChiffre('8')),
                      bouton('9', action: () => ajouterChiffre('9')),
                      bouton('-', couleur: orange,
                          action: () => choisirOperateur('-')),
                    ]),
                    ligne([
                      bouton('4', action: () => ajouterChiffre('4')),
                      bouton('5', action: () => ajouterChiffre('5')),
                      bouton('6', action: () => ajouterChiffre('6')),
                      bouton('+', couleur: orange,
                          action: () => choisirOperateur('+')),
                    ]),
                    Expanded(
                      flex: 2,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              children: [
                                ligne([
                                  bouton('1',
                                      action: () => ajouterChiffre('1')),
                                  bouton('2',
                                      action: () => ajouterChiffre('2')),
                                  bouton('3',
                                      action: () => ajouterChiffre('3')),
                                ]),
                                ligne([
                                  bouton('+/-', action: changerSigne),
                                  bouton('0',
                                      action: () => ajouterChiffre('0')),
                                  bouton('.',
                                      action: () => ajouterChiffre('.')),
                                ]),
                              ],
                            ),
                          ),
                          Expanded(
                            child: bouton(
                              '=',
                              couleur: orange,
                              grand: true,
                              action: resultat,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
