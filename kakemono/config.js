// ╔══════════════════════════════════════════════════════════════════╗
// ║  KAKEMONO — MAYI TOGO TOURISM                                    ║
// ║  ✏️  Modifiez ce fichier uniquement. Ne touchez pas kakemono.html ║
// ╚══════════════════════════════════════════════════════════════════╝

const CFG = {

  // ── 🏫 ÉCOLE ──────────────────────────────────────────────────────
  ecole:      "IPNET Institute of Technology",
  filiere:    "Licence Génie Logiciel",
  promo:      "Promotion 2024",
  annee:      "2024–2025",
  logo_ecole: "logo-ipnet.jpg",
  //           ↑ fichier dans le dossier kakemono/ — remplacez par votre logo si besoin

  // ── 📱 APPLICATION ────────────────────────────────────────────────
  app_name:     "Mayi Togo",
  app_subtitle: "Tourism &amp; Discovery Platform",
  slogan_l1:    "Explorez le Togo.",
  slogan_l2:    "Vivez l'expérience.",
  logo_app:     "logo-app.png",
  //             ↑ fichier dans le dossier kakemono/

  // ── 👥 ÉQUIPE ─────────────────────────────────────────────────────
  dev1_nom:   "d'ALMEIDA Mario-F M. N.",
  dev1_role:  "Développeur Full-Stack",
  dev2_nom:   "KPAKPAVI-KPASCO Paola",
  dev2_role:  "Développeur Frontend",
  encadrant:  "M. AMAH Folly",

  // ── 📸 CAPTURES D'ÉCRAN ───────────────────────────────────────────
  // Placez vos fichiers dans  kakemono/screenshots/
  screen1_src:   "screenshots/screen1.jpeg",
  screen1_label: "Accueil",
  screen2_src:   "screenshots/screen2.jpeg",   // téléphone central (plus grand)
  screen2_label: "Exploration",
  screen3_src:   "screenshots/screen3.jpeg",
  screen3_label: "Réservation",

  // ── 📲 QR CODE ────────────────────────────────────────────────────
  qr_src:   "qr-code.png",
  //         ↑ fichier dans le dossier kakemono/
  qr_label: "Scanner pour télécharger l'app",

  // ── ⚡ FONCTIONNALITÉS ────────────────────────────────────────────
  // Couleurs disponibles : fi-green  fi-gold  fi-red  fi-blue  fi-teal  fi-purple
  features: [
    { icon:"🏨", color:"fi-green",  titre:"Réservation en ligne",  desc:"Hébergements et restaurants avec paiement d'acompte mobile" },
    { icon:"🗺️", color:"fi-gold",   titre:"Carte interactive",     desc:"Découverte des lieux touristiques géolocalisés au Togo" },
    { icon:"📅", color:"fi-red",    titre:"Événements culturels",  desc:"Calendrier des fêtes, festivals et événements locaux" },
    { icon:"⭐", color:"fi-teal",   titre:"Avis & évaluations",    desc:"Système de notation et commentaires des touristes" },
    { icon:"👔", color:"fi-blue",   titre:"Espace Professionnel",  desc:"Gestion des services, réservations et statistiques" },
    { icon:"❤️", color:"fi-purple", titre:"Favoris & recherche",   desc:"Sauvegarde des lieux et filtrage avancé par catégorie" },
  ],

  // ── 🛠️ STACK TECHNIQUE ───────────────────────────────────────────
  // Icônes : https://cdn.simpleicons.org/{nom}/{couleur-hex}
  stack: [
    { label:"Flutter",               color:"#54C5F8", icon:"https://cdn.simpleicons.org/flutter/54C5F8" },
    { label:"Django REST Framework", color:"#44B78B", icon:"https://cdn.simpleicons.org/django/44B78B" },
    { label:"PostgreSQL",            color:"#336791", icon:"https://cdn.simpleicons.org/postgresql/336791" },
    { label:"JWT Auth",              color:"#FB015B", icon:"https://cdn.simpleicons.org/jsonwebtokens/FB015B" },
    { label:"Render",                color:"#c8c8c8", icon:"https://cdn.simpleicons.org/render/c8c8c8" },
    { label:"Provider (Flutter)",    color:"#54C5F8", icon:"https://cdn.simpleicons.org/flutter/54C5F8" },
  ],

  // ── 🎨 COULEURS ───────────────────────────────────────────────────
  colors: {
    primary: "#006a44",   // vert togolais
    accent:  "#4dca8a",   // vert clair
    gold:    "#ffcb00",   // jaune togolais
    red:     "#d21034",   // rouge togolais
  },
};
