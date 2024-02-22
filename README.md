# MSPR-FRONT
# Front-End de l'application Wildlens

## Overview
Cette documentation a pour but d'être simple et d'expliquer l'articulation de la partie Front-End de l'application Wildlens sur sa machine. Elle comprend l'installation du projet et des différents scripts flutter (en **Dart**).

## Requirements
Le projet nécéssite l'installation de **Fluter**, **Dart**, et **Android Studio**.
Installation de Flutter : 
*[Pour windows](https://docs.flutter.dev/get-started/install/windows/desktop)
*[Pour Linux](https://docs.flutter.dev/get-started/install/linux)
*[Pour mac](https://docs.flutter.dev/get-started/install/macos/desktop)

Installation de Dart : 
*[Pour tous les OS](https://dart.dev/get-dart)

Installation d'Android Studio : 
*[Android Studio](https://developer.android.com/studio/install)

Il faut ensuite mettre les PATHS de Dart et Flutter dans Android Studio :
![image](https://github.com/DorianFIGUERAS/MSPR-FRONT/assets/127091847/3b85e584-8e51-4fe8-8507-7568c16f2b11)
![image](https://github.com/DorianFIGUERAS/MSPR-FRONT/assets/127091847/6c677a08-eb17-42c3-aa5f-554a3580dffc)

**Récuperer le repository et le cloner dans Android Studio.**

## Préparation pour lancer l'application sur un émulateur 
Il faut télécharger un SDK Android : 
![image](https://github.com/DorianFIGUERAS/MSPR-FRONT/assets/127091847/6cf5c154-266c-45b3-b099-120ebd0f9ac4)

## Composition du Repository (Scripts principaux)
**Scripts (Project>lib)** :
- **main.dart** : Ce script correspond à la page principale de l'application. Il permet l'articulation entre les différentes pages. 
- **history.dart** : Ce script permet de récupérer et d'afficher l'historique des images uploadées et des prédictions retournées à l'utilisateur.
- **authentification.dart** : Ce script permet de s'authentifier pour accéder à l'application. 
- **ForgotPasswordPage.dart** : Ce script permet de faire une demande de réinitialisation de mot de passe auprès de la BDD Firebase. 
- **register.dart** : Ce script permet de s'inscrire sur la BDD pour une première connexion à l'application. 









