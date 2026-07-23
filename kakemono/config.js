// ╔══════════════════════════════════════════════════════════════════╗
// ║  KAKEMONO — MAYI TOGO TOURISM                                    ║
// ║  ✏️  Modifiez ce fichier uniquement. Ne touchez pas kakemono.html ║
// ╚══════════════════════════════════════════════════════════════════╝

const CFG = {

  // ── 🏫 ÉCOLE ──────────────────────────────────────────────────────
  ecole:      "IPNET Institute of Technology",
  filiere:    "Licence Génie Logiciel",
  promo:      "Promotion 2025–2026",
  annee:      "2025–2026",
  logo_ecole: "logo-ipnet.jpg",

  // ── 📱 APPLICATION ────────────────────────────────────────────────
  app_name:     "Mayi",
  app_subtitle: "Tourism & Discovery Platform — Togo",
  hero_tag:     "Application Mobile · PPE 301",
  logo_app:     "logo-app.png",

  // ── 💬 TAGLINE (HTML autorisé, utilisez <em> pour l'accent vert) ──
  tagline:
    "Le tourisme togolais à portée de main :<br/>" +
    "<em>découvrez, réservez, vivez l'expérience.</em>",

  // ── 📸 CAPTURES D'ÉCRAN ───────────────────────────────────────────
  // Placez vos fichiers dans  kakemono/screenshots/
  screen1_src: "screenshots/screen1.jpeg",
  screen2_src: "screenshots/screen2.jpeg",   // téléphone central (plus grand)
  screen3_src: "screenshots/screen3.jpeg",

  // ── 📲 QR CODE ────────────────────────────────────────────────────
  qr_src:   "qr-code.png",
  qr_label: "Scanner pour\ntélécharger l'APK",

  // ── ⚡ FONCTIONNALITÉS (4 max — icônes hexagonales) ───────────────
  // hexClass disponibles : hex-g1 (vert), hex-g2 (bleu), hex-g3 (or), hex-g4 (rouge)
  features: [
    {
      icon: "🏨",
      hexClass: "hex-g1",
      titre: "Découverte des services locaux",
      desc:  "Restaurants, hébergements, activités culturelles et loisirs du Togo centralisés en une seule application."
    },
    {
      icon: "📲",
      hexClass: "hex-g2",
      titre: "Réservation & paiement mobile",
      desc:  "Réservez en ligne et réglez l'acompte directement via T‑Money ou Flooz depuis l'application."
    },
    {
      icon: "👔",
      hexClass: "hex-g3",
      titre: "Espace professionnel intégré",
      desc:  "Publiez vos services, gérez vos réservations et consultez les avis clients depuis votre tableau de bord."
    },
    {
      icon: "🤖",
      hexClass: "hex-g4",
      titre: "Chatbot d'assistance touristique",
      desc:  "Un assistant intelligent guide les visiteurs, répond à leurs questions et facilite la découverte du Togo."
    },
  ],

  // ── 🛠️ STACK TECHNIQUE ───────────────────────────────────────────
  stack: [
    { label: "Python",      icon: "https://cdn.simpleicons.org/python/3776AB" },
    { label: "Django",      icon: "https://cdn.simpleicons.org/django/092E20" },
    { label: "Flutter",     icon: "https://cdn.simpleicons.org/flutter/54C5F8" },
    { label: "PostgreSQL",  icon: "https://cdn.simpleicons.org/postgresql/336791" },
    { label: "JWT",         icon: "https://cdn.simpleicons.org/jsonwebtokens/FB015B" },
    { label: "REST API",    icon: "https://cdn.simpleicons.org/fastapi/009688" },
  ],

  // ── 🖼️ FOOTER TAGLINE (HTML autorisé) ────────────────────────────
  footer_tagline:
    "Le tourisme togolais<br/>à <em>l'ère du numérique</em>",

  // ── 🎨 COULEURS ───────────────────────────────────────────────────
  colors: {
    primary:  "#006a44",   // vert togolais
    accent:   "#00a865",   // vert clair
    gold:     "#ffcb00",   // jaune togolais
    red:      "#d21034",   // rouge togolais
    hero_bg:  "linear-gradient(150deg, #00391f 0%, #00542e 40%, #006a44 75%, #007a50 100%)",
  },
};
