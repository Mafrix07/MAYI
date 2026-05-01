from django.db import models
from users.models import ProfilProfessionnel, Utilisateur 
# Create your models here.
# ─────────────────────────────────────────────────────────────────────────────
# EVENEMENT
# ─────────────────────────────────────────────────────────────────────────────

class Evenement(models.Model):
    """
    Événement local (festival, concert, activité culturelle…).
    Affiché dans le calendrier d'événements de l'app.
    """

    class TypeEvenement(models.TextChoices):
        FESTIVAL    = 'FESTIVAL',    'Festival'
        CONCERT     = 'CONCERT',     'Concert'
        SPORTIF     = 'SPORTIF',     'Événement sportif'
        CULTUREL    = 'CULTUREL',    'Visite culturelle'
        GASTRONOMIE = 'GASTRONOMIE', 'Gastronomie'
        AUTRE       = 'AUTRE',       'Autre'

    # ── Infos de base ─────────────────────────────────────────────────────────
    titre = models.CharField(
        max_length=200,
        verbose_name="Titre de l'événement"
    )

    description = models.TextField(
        verbose_name="Description"
    )

    type_evenement = models.CharField(
        max_length=20,
        choices=TypeEvenement.choices,
        verbose_name="Type d'événement"
    )

    # ── Dates ─────────────────────────────────────────────────────────────────
    date_debut = models.DateTimeField(
        verbose_name="Date et heure de début"
    )

    date_fin = models.DateTimeField(
        blank=True,
        null=True,
        verbose_name="Date et heure de fin"
    )

    # ── Localisation ──────────────────────────────────────────────────────────
    lieu = models.CharField(
        max_length=300,
        verbose_name="Lieu"
    )

    latitude = models.DecimalField(
        max_digits=9,
        decimal_places=6,
        blank=True,
        null=True,
        verbose_name="Latitude"
    )

    longitude = models.DecimalField(
        max_digits=9,
        decimal_places=6,
        blank=True,
        null=True,
        verbose_name="Longitude"
    )

    # ── Organisateur (optionnel : peut être lié à un Pro) ─────────────────────
    organisateur = models.ForeignKey(
        ProfilProfessionnel,
        on_delete=models.SET_NULL,
        related_name='evenements',
        blank=True,
        null=True,
        verbose_name="Organisateur (Professionnel)"
    )

    image = models.ImageField(
        upload_to='evenements/',
        blank=True,
        null=True,
        verbose_name="Image de l'événement"
    )

    est_actif = models.BooleanField(
        default=True,
        verbose_name="Événement actif"
    )

    date_creation = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.titre} — {self.date_debut.strftime('%d/%m/%Y')}"

    class Meta:
        verbose_name = "Événement"
        verbose_name_plural = "Événements"
        ordering = ['date_debut']


# ─────────────────────────────────────────────────────────────────────────────
# NOTIFICATION
# ─────────────────────────────────────────────────────────────────────────────

class Notification(models.Model):
    """
    Notification envoyée à un utilisateur.
    (confirmation de réservation, promotion, nouvel événement…)
    """

    class TypeNotification(models.TextChoices):
        RESERVATION  = 'RESERVATION',  'Réservation'
        PROMOTION    = 'PROMOTION',     'Promotion'
        EVENEMENT    = 'EVENEMENT',     'Nouvel événement'
        AVIS         = 'AVIS',          'Nouvel avis'
        SYSTEME      = 'SYSTEME',       'Système'

    # ── Relations ─────────────────────────────────────────────────────────────
    destinataire = models.ForeignKey(
        Utilisateur,
        on_delete=models.CASCADE,
        related_name='notifications',
        verbose_name="Destinataire"
    )

    # ── Contenu ───────────────────────────────────────────────────────────────
    type_notification = models.CharField(
        max_length=20,
        choices=TypeNotification.choices,
        verbose_name="Type de notification"
    )

    titre = models.CharField(
        max_length=200,
        verbose_name="Titre"
    )

    message = models.TextField(
        verbose_name="Message"
    )

    # ── Statut ────────────────────────────────────────────────────────────────
    est_lu = models.BooleanField(
        default=False,
        verbose_name="Lu"
    )

    date_creation = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        statut = "✓" if self.est_lu else "●"
        return f"[{statut}] {self.titre} → {self.destinataire.username}"

    class Meta:
        verbose_name = "Notification"
        verbose_name_plural = "Notifications"
        ordering = ['-date_creation']