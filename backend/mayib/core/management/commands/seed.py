# ─────────────────────────────────────────────────────────────────────────────
# FICHIER : core/management/commands/seed.py
#
# Pour créer ce fichier, crée les dossiers suivants dans ton app core :
#   core/
#   └── management/
#       ├── __init__.py
#       └── commands/
#           ├── __init__.py
#           └── seed.py   ← ce fichier
#
# Ensuite lance avec : python manage.py seed
# Pour repartir de zéro : python manage.py seed --flush
# ─────────────────────────────────────────────────────────────────────────────

from django.core.management.base import BaseCommand
from django.utils import timezone
from decimal import Decimal
from datetime import date, time, timedelta
import random

from users.models import Utilisateur, ProfilTouriste, ProfilProfessionnel
from services.models import Service, PhotoService
from reservations.models import Reservation, PaiementAcompte, PaiementSolde
from reviews.models import Avis
from support.models import Ticket, MessageTicket
from core.models import Notification, Evenement


class Command(BaseCommand):
    help = "Peuple la base de données avec des données de test pour Mayi"

    def add_arguments(self, parser):
        parser.add_argument(
            '--flush',
            action='store_true',
            help='Supprime toutes les données avant de seeder'
        )

    def handle(self, *args, **options):
        if options['flush']:
            self.stdout.write(self.style.WARNING('🗑️  Suppression des données existantes...'))
            self._flush()

        self.stdout.write(self.style.MIGRATE_HEADING('\n🌱 Démarrage du seeding — Mayi Togo Tourism\n'))

        utilisateurs   = self._creer_utilisateurs()
        professionnels = self._creer_professionnels(utilisateurs)
        services       = self._creer_services(professionnels)
        reservations   = self._creer_reservations(utilisateurs, services)
        self._creer_avis(utilisateurs, services)
        self._creer_evenements(professionnels)
        self._creer_notifications(utilisateurs, reservations)
        self._creer_tickets(utilisateurs, reservations)

        self.stdout.write(self.style.SUCCESS('\n✅ Seeding terminé avec succès !\n'))
        self._afficher_recap()

    # ─────────────────────────────────────────────────────────────────────────
    # FLUSH
    # ─────────────────────────────────────────────────────────────────────────

    def _flush(self):
        MessageTicket.objects.all().delete()
        Ticket.objects.all().delete()
        Notification.objects.all().delete()
        Evenement.objects.all().delete()
        Avis.objects.all().delete()
        PaiementSolde.objects.all().delete()
        PaiementAcompte.objects.all().delete()
        Reservation.objects.all().delete()
        PhotoService.objects.all().delete()
        Service.objects.all().delete()
        ProfilProfessionnel.objects.all().delete()
        ProfilTouriste.objects.all().delete()
        Utilisateur.objects.filter(is_superuser=False).delete()
        self.stdout.write(self.style.SUCCESS('   Données supprimées.'))

    # ─────────────────────────────────────────────────────────────────────────
    # UTILISATEURS
    # ─────────────────────────────────────────────────────────────────────────

    def _creer_utilisateurs(self):
        self.stdout.write('👤 Création des utilisateurs...')

        utilisateurs = {}

        # Admin
        admin, _ = Utilisateur.objects.get_or_create(
            username='admin_mayi',
            defaults={
                'email': 'admin@mayi.tg',
                'first_name': 'Admin',
                'last_name': 'Mayi',
                'role': Utilisateur.Role.ADMIN,
                'is_staff': True,
                'is_superuser': True,
            }
        )
        admin.set_password('admin1234')
        admin.save()
        utilisateurs['admin'] = admin

        # Support
        support, _ = Utilisateur.objects.get_or_create(
            username='support_mayi',
            defaults={
                'email': 'support@mayi.tg',
                'first_name': 'Claire',
                'last_name': 'Agbedigni',
                'role': Utilisateur.Role.SUPPORT,
                'telephone': '+22890000002',
            }
        )
        support.set_password('support1234')
        support.save()
        utilisateurs['support'] = support

        # Professionnels
        pros_data = [
            ('hotel_sarakawa', 'sarakawa@mayi.tg', 'Kodjo', 'Sarakawa', '+22891000001'),
            ('chez_alice',     'alice@mayi.tg',    'Alice', 'Mensah',   '+22891000002'),
            ('aventure_togo',  'aventure@mayi.tg', 'Yawo',  'Koffi',    '+22891000003'),
        ]
        utilisateurs['pros'] = []
        for username, email, fn, ln, tel in pros_data:
            u, _ = Utilisateur.objects.get_or_create(
                username=username,
                defaults={
                    'email': email, 'first_name': fn, 'last_name': ln,
                    'role': Utilisateur.Role.PROFESSIONNEL, 'telephone': tel,
                }
            )
            u.set_password('pro1234')
            u.save()
            utilisateurs['pros'].append(u)

        # Touristes
        touristes_data = [
            ('paola_touriste', 'paola@gmail.com',  'Paola',   'Kpasco',   'TG', '+22892000001'),
            ('mario_touriste', 'mario@gmail.com',  'Mario',   'dAlmeida', 'TG', '+22892000002'),
            ('sophie_paris',   'sophie@gmail.com', 'Sophie',  'Dubois',   'FR', '+33600000001'),
            ('john_london',    'john@gmail.com',   'John',    'Smith',     'GB', '+44700000001'),
            ('aminata_dakar',  'aminata@gmail.com','Aminata', 'Diallo',   'SN', '+22170000001'),
        ]
        utilisateurs['touristes'] = []
        for username, email, fn, ln, nat, tel in touristes_data:
            u, created = Utilisateur.objects.get_or_create(
                username=username,
                defaults={
                    'email': email, 'first_name': fn, 'last_name': ln,
                    'role': Utilisateur.Role.TOURISTE, 'telephone': tel,
                }
            )
            u.set_password('touriste1234')
            u.save()
            # Met à jour la nationalité dans le profil touriste
            if hasattr(u, 'profil_touriste'):
                u.profil_touriste.nationalite = nat
                u.profil_touriste.save()
            utilisateurs['touristes'].append(u)

        self.stdout.write(self.style.SUCCESS(f'   ✓ {Utilisateur.objects.count()} utilisateurs créés'))
        return utilisateurs

    # ─────────────────────────────────────────────────────────────────────────
    # PROFESSIONNELS
    # ─────────────────────────────────────────────────────────────────────────

    def _creer_professionnels(self, utilisateurs):
        self.stdout.write('🏢 Création des profils professionnels...')

        pros_info = [
            ('Hôtel Sarakawa',       'Hôtel 5 étoiles au cœur de Lomé',       'Bd du Mono, Lomé',         'https://sarakawa.tg',  True),
            ('Chez Alice Restaurant','Restaurant traditionnel togolais',        'Quartier Bè, Lomé',        '',                     True),
            ('Aventure Togo',        'Agence de randonnées et excursions',      'Kpalimé, Plateaux',        'https://aventuretogo.tg', True),
        ]

        professionnels = []
        for u, (nom, desc, adresse, site, verifie) in zip(utilisateurs['pros'], pros_info):
            profil, _ = ProfilProfessionnel.objects.get_or_create(
                utilisateur=u,
                defaults={
                    'nom_etablissement': nom,
                    'description_etablissement': desc,
                    'adresse': adresse,
                    'site_web': site,
                    'est_verifie': verifie,
                }
            )
            professionnels.append(profil)

        self.stdout.write(self.style.SUCCESS(f'   ✓ {len(professionnels)} profils professionnels créés'))
        return professionnels

    # ─────────────────────────────────────────────────────────────────────────
    # SERVICES
    # ─────────────────────────────────────────────────────────────────────────

    def _creer_services(self, professionnels):
        self.stdout.write('🏨 Création des services...')

        services_data = [
            # Hôtel Sarakawa
            {
                'nom': 'Chambre Standard — Hôtel Sarakawa',
                'description': 'Chambre climatisée avec vue sur jardin, petit-déjeuner inclus.',
                'type_service': Service.TypeService.HEBERGEMENT,
                'prix': Decimal('45000'),
                'prix_min': Decimal('40000'),
                'prix_max': Decimal('55000'),
                'adresse': 'Bd du Mono, Lomé',
                'latitude': Decimal('6.1375'),
                'longitude': Decimal('1.2123'),
                'horaire_ouverture': time(0, 0),
                'horaire_fermeture': time(23, 59),
                'professionnel': professionnels[0],
            },
            {
                'nom': 'Suite Présidentielle — Hôtel Sarakawa',
                'description': 'Suite luxueuse avec salon, jacuzzi et vue panoramique sur Lomé.',
                'type_service': Service.TypeService.HEBERGEMENT,
                'prix': Decimal('120000'),
                'prix_min': Decimal('100000'),
                'prix_max': Decimal('150000'),
                'adresse': 'Bd du Mono, Lomé',
                'latitude': Decimal('6.1375'),
                'longitude': Decimal('1.2123'),
                'horaire_ouverture': time(0, 0),
                'horaire_fermeture': time(23, 59),
                'professionnel': professionnels[0],
            },
            # Chez Alice
            {
                'nom': 'Table chez Alice',
                'description': 'Cuisine togolaise authentique : fufu, gboma dessi, akoumé.',
                'type_service': Service.TypeService.SNACK,
                'prix': Decimal('5000'),
                'prix_min': None,
                'prix_max': None,
                'adresse': 'Quartier Bè, Lomé',
                'latitude': Decimal('6.1220'),
                'longitude': Decimal('1.2250'),
                'horaire_ouverture': time(11, 0),
                'horaire_fermeture': time(22, 0),
                'options_livraison': True,
                'professionnel': professionnels[1],
            },
            # Aventure Togo
            {
                'nom': 'Randonnée Mont Agou',
                'description': 'Excursion guidée au sommet du Mont Agou, point culminant du Togo (986m).',
                'type_service': Service.TypeService.ACTIVITE,
                'prix': Decimal('15000'),
                'prix_min': None,
                'prix_max': None,
                'adresse': 'Mont Agou, Kpalimé',
                'latitude': Decimal('6.8667'),
                'longitude': Decimal('0.7500'),
                'horaire_ouverture': time(6, 0),
                'horaire_fermeture': time(18, 0),
                'professionnel': professionnels[2],
            },
            {
                'nom': 'Visite Cascades de Kpimé',
                'description': 'Découverte des magnifiques cascades de Kpimé en pleine forêt tropicale.',
                'type_service': Service.TypeService.ACTIVITE,
                'prix': Decimal('10000'),
                'prix_min': None,
                'prix_max': None,
                'adresse': 'Kpimé, Kpalimé',
                'latitude': Decimal('6.9500'),
                'longitude': Decimal('0.6300'),
                'horaire_ouverture': time(7, 0),
                'horaire_fermeture': time(17, 0),
                'professionnel': professionnels[2],
            },
        ]

        services = []
        for data in services_data:
            s, _ = Service.objects.get_or_create(
                nom=data['nom'],
                defaults=data
            )
            services.append(s)

        self.stdout.write(self.style.SUCCESS(f'   ✓ {len(services)} services créés'))
        return services

    # ─────────────────────────────────────────────────────────────────────────
    # RESERVATIONS
    # ─────────────────────────────────────────────────────────────────────────

    def _creer_reservations(self, utilisateurs, services):
        self.stdout.write('📅 Création des réservations...')

        today = date.today()
        reservations = []

        reservations_data = [
            # Réservation hébergement confirmée (acompte payé via Flooz)
            {
                'touriste': utilisateurs['touristes'][2],  # Sophie
                'service': services[0],                    # Chambre Standard
                'type_reservation': Reservation.TypeReservation.HEBERGEMENT,
                'statut': Reservation.Statut.CONFIRMEE,
                'date_debut': today + timedelta(days=5),
                'date_fin': today + timedelta(days=8),
                'nombre_personnes': 2,
                'prix_total': Decimal('135000'),
                'type_acompte': Reservation.TypeAcompte.POURCENTAGE,
                'valeur_acompte': Decimal('30'),
                'montant_acompte': Decimal('40500'),
                'solde_restant': Decimal('94500'),
                'paiement': {
                    'operateur': PaiementAcompte.Operateur.FLOOZ,
                    'mode_verification': 'AUTOMATIQUE',
                    'numero_telephone': '+33600000001',
                    'reference_transaction': 'FLZ20250101ABC',
                    'statut_paiement': PaiementAcompte.StatutPaiement.VALIDE,
                }
            },
            # Réservation table en attente de vérification (T-Money)
            {
                'touriste': utilisateurs['touristes'][0],  # Paola
                'service': services[2],                    # Chez Alice
                'type_reservation': Reservation.TypeReservation.TABLE,
                'statut': Reservation.Statut.ACOMPTE_EN_VERIFICATION,
                'date_debut': today + timedelta(days=2),
                'date_fin': None,
                'heure_reservation': time(19, 30),
                'nombre_personnes': 4,
                'prix_total': Decimal('20000'),
                'type_acompte': Reservation.TypeAcompte.MONTANT_FIXE,
                'valeur_acompte': Decimal('5000'),
                'montant_acompte': Decimal('5000'),
                'solde_restant': Decimal('15000'),
                'paiement': {
                    'operateur': PaiementAcompte.Operateur.TMONEY,
                    'mode_verification': 'MANUELLE',
                    'numero_telephone': '+22892000001',
                    'reference_transaction': 'TMN20250102XYZ',
                    'statut_paiement': PaiementAcompte.StatutPaiement.EN_COURS,
                }
            },
            # Réservation terminée (acompte + solde payés)
            {
                'touriste': utilisateurs['touristes'][3],  # John
                'service': services[3],                    # Randonnée Mont Agou
                'type_reservation': Reservation.TypeReservation.HEBERGEMENT,
                'statut': Reservation.Statut.TERMINEE,
                'date_debut': today - timedelta(days=10),
                'date_fin': today - timedelta(days=9),
                'nombre_personnes': 1,
                'prix_total': Decimal('15000'),
                'type_acompte': Reservation.TypeAcompte.POURCENTAGE,
                'valeur_acompte': Decimal('50'),
                'montant_acompte': Decimal('7500'),
                'solde_restant': Decimal('7500'),
                'solde_paye': True,
                'paiement': {
                    'operateur': PaiementAcompte.Operateur.FLOOZ,
                    'mode_verification': 'AUTOMATIQUE',
                    'numero_telephone': '+44700000001',
                    'reference_transaction': 'FLZ20241220DEF',
                    'statut_paiement': PaiementAcompte.StatutPaiement.VALIDE,
                }
            },
        ]

        for data in reservations_data:
            paiement_data = data.pop('paiement')

            r, created = Reservation.objects.get_or_create(
                touriste=data['touriste'],
                service=data['service'],
                date_debut=data['date_debut'],
                defaults=data
            )

            if created:
                # Crée le paiement acompte associé
                PaiementAcompte.objects.get_or_create(
                    reservation=r,
                    defaults={
                        **paiement_data,
                        'montant': r.montant_acompte,
                        'valide_par': utilisateurs['pros'][
                            0 if paiement_data['operateur'] == PaiementAcompte.Operateur.FLOOZ else 1
                        ],
                        'date_validation': timezone.now() if paiement_data['statut_paiement'] == PaiementAcompte.StatutPaiement.VALIDE else None,
                    }
                )

                # Si terminée, crée aussi le paiement solde
                if r.statut == Reservation.Statut.TERMINEE:
                    PaiementSolde.objects.get_or_create(
                        reservation=r,
                        defaults={
                            'montant': r.solde_restant,
                            'mode_paiement': PaiementSolde.ModePaiement.ESPECES,
                            'confirme_par': utilisateurs['pros'][2],
                        }
                    )

            reservations.append(r)

        self.stdout.write(self.style.SUCCESS(f'   ✓ {len(reservations)} réservations créées'))
        return reservations

    # ─────────────────────────────────────────────────────────────────────────
    # AVIS
    # ─────────────────────────────────────────────────────────────────────────

    def _creer_avis(self, utilisateurs, services):
        self.stdout.write('⭐ Création des avis...')

        avis_data = [
            (utilisateurs['touristes'][2], services[0], 5, "Hôtel magnifique, personnel très accueillant !"),
            (utilisateurs['touristes'][3], services[0], 4, "Très bon séjour, chambre propre et confortable."),
            (utilisateurs['touristes'][0], services[2], 5, "La meilleure cuisine togolaise de Lomé, un régal !"),
            (utilisateurs['touristes'][1], services[2], 4, "Délicieux, je recommande le fufu et le gboma."),
            (utilisateurs['touristes'][3], services[3], 5, "Randonnée inoubliable, guide très professionnel."),
            (utilisateurs['touristes'][4], services[4], 4, "Cascades magnifiques, paysage à couper le souffle."),
        ]

        count = 0
        for touriste, service, note, commentaire in avis_data:
            _, created = Avis.objects.get_or_create(
                touriste=touriste,
                service=service,
                defaults={'note': note, 'commentaire': commentaire}
            )
            if created:
                count += 1

        self.stdout.write(self.style.SUCCESS(f'   ✓ {count} avis créés'))

    # ─────────────────────────────────────────────────────────────────────────
    # EVENEMENTS
    # ─────────────────────────────────────────────────────────────────────────

    def _creer_evenements(self, professionnels):
        self.stdout.write('🎉 Création des événements...')

        today = date.today()
        evenements_data = [
            {
                'titre': 'Festival FITHEB Lomé 2025',
                'description': 'Festival International de Théâtre et des Arts du Bénin et du Togo.',
                'type_evenement': Evenement.TypeEvenement.FESTIVAL,
                'date_debut': timezone.make_aware(timezone.datetime(today.year, today.month, today.day, 18, 0) + timedelta(days=15)),
                'date_fin': timezone.make_aware(timezone.datetime(today.year, today.month, today.day, 23, 0) + timedelta(days=20)),
                'lieu': 'Palais des Congrès, Lomé',
                'latitude': Decimal('6.1319'),
                'longitude': Decimal('1.2228'),
            },
            {
                'titre': 'Nuit Culturelle de Kpalimé',
                'description': 'Soirée de musique traditionnelle éwé et exposition d\'artisanat local.',
                'type_evenement': Evenement.TypeEvenement.CULTUREL,
                'date_debut': timezone.make_aware(timezone.datetime(today.year, today.month, today.day, 19, 0) + timedelta(days=7)),
                'date_fin': timezone.make_aware(timezone.datetime(today.year, today.month, today.day, 23, 30) + timedelta(days=7)),
                'lieu': 'Place centrale, Kpalimé',
                'latitude': Decimal('6.8994'),
                'longitude': Decimal('0.6342'),
                'organisateur': professionnels[2],
            },
            {
                'titre': 'Marathon de Lomé 2025',
                'description': 'Course annuelle de 42km le long du bord de mer de Lomé.',
                'type_evenement': Evenement.TypeEvenement.SPORTIF,
                'date_debut': timezone.make_aware(timezone.datetime(today.year, today.month, today.day, 6, 0) + timedelta(days=30)),
                'lieu': 'Bord de mer, Lomé',
                'latitude': Decimal('6.1361'),
                'longitude': Decimal('1.2156'),
            },
        ]

        count = 0
        for data in evenements_data:
            _, created = Evenement.objects.get_or_create(
                titre=data['titre'],
                defaults=data
            )
            if created:
                count += 1

        self.stdout.write(self.style.SUCCESS(f'   ✓ {count} événements créés'))

    # ─────────────────────────────────────────────────────────────────────────
    # NOTIFICATIONS
    # ─────────────────────────────────────────────────────────────────────────

    def _creer_notifications(self, utilisateurs, reservations):
        self.stdout.write('🔔 Création des notifications...')

        notifs_data = [
            (utilisateurs['touristes'][2], Notification.TypeNotification.RESERVATION,
             'Réservation confirmée !', f'Votre réservation #{reservations[0].pk} a été confirmée. À bientôt à Lomé !'),
            (utilisateurs['touristes'][0], Notification.TypeNotification.RESERVATION,
             'Acompte en vérification', f'Votre acompte pour la réservation #{reservations[1].pk} est en cours de vérification.'),
            (utilisateurs['touristes'][0], Notification.TypeNotification.PROMOTION,
             'Offre spéciale — Chez Alice', 'Profitez de -20% sur votre prochaine réservation ce weekend !'),
            (utilisateurs['touristes'][3], Notification.TypeNotification.EVENEMENT,
             'Nouveau festival à Lomé', 'Le Festival FITHEB commence dans 15 jours, ne le manquez pas !'),
        ]

        count = 0
        for destinataire, type_notif, titre, message in notifs_data:
            Notification.objects.create(
                destinataire=destinataire,
                type_notification=type_notif,
                titre=titre,
                message=message
            )
            count += 1

        self.stdout.write(self.style.SUCCESS(f'   ✓ {count} notifications créées'))

    # ─────────────────────────────────────────────────────────────────────────
    # TICKETS
    # ─────────────────────────────────────────────────────────────────────────

    def _creer_tickets(self, utilisateurs, reservations):
        self.stdout.write('🎫 Création des tickets de support...')

        support = utilisateurs['support']

        ticket, created = Ticket.objects.get_or_create(
            utilisateur=utilisateurs['touristes'][0],
            sujet='Demande d\'annulation réservation table',
            defaults={
                'type_ticket': Ticket.TypeTicket.ANNULATION,
                'description': 'Je souhaite annuler ma réservation de table chez Alice prévue dans 2 jours. Pouvez-vous m\'aider ?',
                'statut': Ticket.Statut.EN_COURS,
                'assigne_a': support,
                'reservation': reservations[1],
            }
        )

        if created:
            MessageTicket.objects.create(
                ticket=ticket,
                auteur=utilisateurs['touristes'][0],
                contenu="Bonjour, j'ai un empêchement et je dois annuler. Merci de votre compréhension."
            )
            MessageTicket.objects.create(
                ticket=ticket,
                auteur=support,
                contenu="Bonjour, nous avons bien reçu votre demande. Nous traitons votre dossier sous 24h."
            )

        self.stdout.write(self.style.SUCCESS(f'   ✓ Tickets créés'))

    # ─────────────────────────────────────────────────────────────────────────
    # RÉCAPITULATIF
    # ─────────────────────────────────────────────────────────────────────────

    def _afficher_recap(self):
        self.stdout.write(self.style.MIGRATE_HEADING('📊 Récapitulatif :'))
        self.stdout.write(f'   Utilisateurs   : {Utilisateur.objects.count()}')
        self.stdout.write(f'   Services       : {Service.objects.count()}')
        self.stdout.write(f'   Réservations   : {Reservation.objects.count()}')
        self.stdout.write(f'   Avis           : {Avis.objects.count()}')
        self.stdout.write(f'   Événements     : {Evenement.objects.count()}')
        self.stdout.write(f'   Notifications  : {Notification.objects.count()}')
        self.stdout.write(f'   Tickets        : {Ticket.objects.count()}')
        self.stdout.write('')
        self.stdout.write('   Comptes de test :')
        self.stdout.write('   admin_mayi    / admin1234     (Admin)')
        self.stdout.write('   support_mayi  / support1234   (Support)')
        self.stdout.write('   hotel_sarakawa/ pro1234       (Professionnel)')
        self.stdout.write('   paola_touriste/ touriste1234  (Touriste)')
