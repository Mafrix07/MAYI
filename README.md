# 🌴 MAYI TOGO TOURISM — Plateforme Touristique & Écosystème Local

[![Django](https://img.shields.io/badge/Backend-Django%205.2-092E20?style=for-the-badge&logo=django)](https://www.djangoproject.com/)
[![Django REST Framework](https://img.shields.io/badge/API-Django%20REST-red?style=for-the-badge&logo=django)](https://www.django-rest-framework.org/)
[![Flutter](https://img.shields.io/badge/Frontend-Flutter%203.x-02569B?style=for-the-badge&logo=flutter)](https://flutter.dev/)
[![Python](https://img.shields.io/badge/Python-3.11+-3776AB?style=for-the-badge&logo=python)](https://www.python.org/)
[![PostgreSQL](https://img.shields.io/badge/Database-PostgreSQL-4169E1?style=for-the-badge&logo=postgresql)](https://www.postgresql.org/)
[![Swagger](https://img.shields.io/badge/Docs-Swagger%2FReDoc-85EA2D?style=for-the-badge&logo=swagger)](http://localhost:8000/api/docs/)
[![License](https://img.shields.io/badge/Status-Livrable%20PPE%20301-success?style=for-the-badge)](#)

> **Projet d'Étude & Livrable PPE 301** (Année Universitaire 2025-2026)  
> **Auteur :** Mario-Francisco d'ALMEIDA

---

## 📌 Présentation & Problématique

Le Togo dispose d'un potentiel touristique exceptionnel : plages de sable fin, forêts luxuriantes, artisanat local, richesses gastronomiques et sites historiques remarquables (Lomé, Kpalimé, Togoville, Kara...). Cependant, les voyageurs et résidents manquent d'un outil numérique centralisé pour découvrir et réserver des hébergements, restaurants, guides ou activités culturelles de proximité.

Les grandes plateformes internationales (Booking, TripAdvisor) se concentrent sur les grands établissements internationaux nécessitant des cartes bancaires. Le tissu économique local togolais reste ainsi largement invisible.

**MAYI TOGO TOURISM** répond à ce défi en proposant une solution mobile et web sur-mesure connectant directement les touristes aux prestataires locaux avec une intégration des modes de paiement mobiles populaires (T-Money & Flooz).

---

## ✨ Fonctionnalités Principales

### 📱 Espace Touriste (Application Mobile Flutter)
* **Découverte & Catalogue :** Exploration dynamique des services par catégorie (Hébergements, Restaurants, Guides, Activités).
* **Recherche & Filtres Avancés :** Filtrage par prix, type de prestation, localisation et note moyenne.
* **Fiches Détaillées & Favoris :** Consultation des détails, photos, tarifs, avis et sauvegarde en favoris.
* **Système de Réservation :** Prise de réservation avec gestion des statuts (`EN_ATTENTE`, `CONFIRMEE`, `ANNULEE`).
* **Paiement Mobile Local (Bonus) :** Acompte via **T-Money** ou **Flooz** avec envoi de preuve/capture d'écran.
* **Gestion du Profil :** Historique de réservation, modification des informations personnelles et photo de profil.

### 💼 Espace Professionnel (Prestataire de Service)
* **Gestion de Vitrine :** Création, modification et suppression de services (photos, descriptions, tarifs).
* **Gestion des Demandes :** Réception et validation/refus des demandes de réservations en temps réel.
* **Suivi des Paiements :** Vérification des captures d'écran de règlement mobile transmises par les clients.
* **Avis Clients :** Consultation des avis et notes déposés par la communauté.
* **Tableau de Bord :** Interface synthétique pour suivre l'activité de son établissement.

### 🖥️ Espace Administration (Web Dashboard Bootstrap)
* **Statistiques Globales :** Vue d'ensemble des utilisateurs, services enregistrés et réservations.
* **Modération & Sécurité :** Activation/désactivation de comptes utilisateurs ou de services litigieux.
* **Gestion des Avis :** Suppression des avis inappropriés ou non conformes.

### 🤖 Chatbot IA Touristique (Bonus)
* Assistant intelligent intégré basé sur l'**API Google Gemini**, formé pour orienter les visiteurs et répondre aux questions sur le tourisme au Togo.

---

## 🛠️ Architecture & Stack Technique

### Backend (API REST)
* **Framework :** Python 5.2 / Django REST Framework (DRF)
* **Authentification :** JWT (`djangorestframework-simplejwt`) avec gestion fine des rôles (`Touriste`, `Professionnel`, `Admin`).
* **Documentation OpenAPI :** Swagger UI & ReDoc via `drf-spectacular`.
* **Base de données :** PostgreSQL (Production) / SQLite (Développement).
* **Déploiement :** Prêt pour Render / Railway (`render.yaml`, `Procfile`, Gunicorn, WhiteNoise).

### Frontend Mobile
* **Framework :** Flutter 3.x (Dart) Cross-platform (Android & iOS).
* **Design :** Material 3 avec Support Dark/Light mode natif & Shimmer Loading effects.
* **State Management :** Provider architecture.
* **Stockage Sécurisé :** `flutter_secure_storage` & `shared_preferences`.

---

## 📁 Structure du Projet

```text
MAYI_PROJET1/
├── backend/                  # Application Backend Django
│   └── mayib/
│       ├── api/              # Inclusions & Serializers d'API
│       ├── chatbot/          # Module d'assistance IA (Gemini)
│       ├── core/             # Événements & Notifications
│       ├── dashboard/        # Vue & Dashboard Admin Web
│       ├── reservations/     # Logique des réservations & paiements T-Money/Flooz
│       ├── reviews/          # Modération & Gestion des avis
│       ├── services/         # Catalogue des offres touristiques
│       ├── support/          # Module de ticketing & support
│       ├── users/            # Gestion Utilisateurs, Profils & Authentification JWT
│       ├── manage.py         # Script d'exécution Django
│       ├── requirements.txt  # Dépendances Python
│       └── schema.yaml       # Spécification OpenAPI / Swagger
│
├── frontend/                 # Application Mobile Flutter
│   └── mayif/
│       ├── lib/              # Code source Dart (Screens, Providers, Models, Widgets)
│       ├── assets/           # Images, Icônes & Logos
│       └── pubspec.yaml      # Dépendances Flutter
│
├── LIVRABLESPPE301/          # Documents de présentation & Analyse
│   ├── BUSINESS_PLAN_MayiTogoTOURISM.pdf
│   ├── DOCUMENT_D'ANALYSE_FONCTIONELLE.pdf
│   ├── Manuel_Deploiement.pdf
│   ├── manuel_utilisation.pdf
│   ├── cahier_charge.pdf
│   └── kakemono.png
│
├── postman/                  # Collection & Environnements Postman pour tester les APIs
├── PRESENTATION_JURY.txt     # Support textuel de présentation orale PPE 301
└── render.yaml               # Fichier d'orchestration de déploiement Render
```

---

## 🚀 Installation & Démarrage Rapide

### 1. Prérequis
* Python 3.11+
* Flutter SDK 3.x
* Git

---

### 2. Lancement du Backend (Django)

```bash
# 1. Naviguer dans le dossier backend
cd backend/mayib

# 2. Créer et activer l'environnement virtuel Python
python -m venv venv
# Sur Windows :
venv\Scripts\activate
# Sur Linux/macOS :
source venv/bin/activate

# 3. Installer les dépendances
pip install -r requirements.txt

# 4. Configurer les variables d'environnement
# Renseigner un fichier .env ou credentials.env avec SECRET_KEY, DEBUG, DATABASE_URL, etc.

# 5. Appliquer les migrations de base de données
python manage.py migrate

# 6. Lancer le serveur de développement
python manage.py runserver
```

L'API sera disponible sur : `http://127.0.0.1:8000/api/`  
La documentation Swagger est accessible sur : `http://127.0.0.1:8000/api/docs/`

---

### 3. Lancement du Frontend (Flutter)

```bash
# 1. Naviguer dans le dossier frontend
cd frontend/mayif

# 2. Récupérer les paquets Flutter
flutter pub get

# 3. Exécuter l'application (sur émulateur ou appareil connecté)
flutter run
```

---

## 📖 Endpoints Principaux de l'API REST

| Domaine | Méthode | Endpoint | Description |
| :--- | :--- | :--- | :--- |
| **Auth** | `POST` | `/api/auth/register/` | Inscription utilisateur (Touriste / Pro) |
| **Auth** | `POST` | `/api/auth/login/` | Obtenir le token JWT |
| **Auth** | `GET` | `/api/auth/me/` | Obtenir le profil de l'utilisateur connecté |
| **Services**| `GET` | `/api/services/` | Lister les services touristiques (avec filtres) |
| **Services**| `POST` | `/api/services/` | Ajouter un nouveau service (Réservé Pro) |
| **Réservations**| `POST` | `/api/reservations/` | Créer une réservation |
| **Réservations**| `GET` | `/api/reservations/` | Liste des réservations de l'utilisateur |
| **Avis** | `POST` | `/api/reviews/` | Laisser un avis sur un service |
| **Chatbot** | `POST` | `/api/chatbot/` | Poser une question à l'assistant IA Gemini |
| **Docs** | `GET` | `/api/docs/` | Interface Swagger UI |

---

## 📄 Livrables & Documentation PDF

Tous les documents officiels du projet sont regroupés sous le dossier [`LIVRABLESPPE301/`](./LIVRABLESPPE301/) :
* 📘 **Document d'Analyse Fonctionnelle** (`DOCUMENT_D'ANALYSE_FONCTIONELLE.pdf`)
* 💼 **Business Plan** (`BUSINESS_PLAN_MayiTogoTOURISM.pdf`)
* 📖 **Manuel d'Utilisation** (`manuel_utilisation.pdf`)
* 🚀 **Manuel de Déploiement** (`Manuel_Deploiement.pdf`)
* 📋 **Cahier des Charges Initial** (`cahier_charge.pdf`)

---

## 👤 Auteur & Contexte Projet

* **Projet :** PPE 301 — Année Universitaire 2025-2026
* **Développeur / Réalisation :** Mario-Francisco d'ALMEIDA
* **Note de contexte :** Développement intégral (Backend REST API, Frontend Mobile Flutter, Dashboard Web Bootstrap et documentation) réalisé de manière autonome.

---

<p align="center">
  <i>MAYI TOGO TOURISM — Promouvoir le tourisme local et valoriser les acteurs économiques du Togo.</i> 🇹🇬
</p>
