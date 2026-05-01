from django.db import models
from users.models import ProfilProfessionnel
 
 
class Service(models.Model):
    """
    Modèle principal représentant un service touristique
    (hébergement, snack/restaurant, activité, transport).
    """
 
    class TypeService(models.TextChoices):
        HEBERGEMENT = 'HEBERGEMENT', 'Hébergement'
        SNACK       = 'SNACK',       'Snack / Restaurant'
        ACTIVITE    = 'ACTIVITE',    'Activité / Loisir'
        TRANSPORT   = 'TRANSPORT',   'Transport'
 
    # ── Infos de base ────────────────────────────────────────────────────────
    nom = models.CharField(
        max_length=200,
        verbose_name="Nom du service"
    )
 
    description = models.TextField(
        verbose_name="Description"
    )
 
    type_service = models.CharField(
        max_length=20,
        choices=TypeService.choices,
        verbose_name="Type de service"
    )
 
    # ── Prix ─────────────────────────────────────────────────────────────────
    prix = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        verbose_name="Prix (FCFA)"
    )
 
    prix_min = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        blank=True,
        null=True,
        verbose_name="Prix minimum (pour comparateur)"
    )
 
    prix_max = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        blank=True,
        null=True,
        verbose_name="Prix maximum (pour comparateur)"
    )
 
    # ── Localisation ─────────────────────────────────────────────────────────
    adresse = models.CharField(
        max_length=300,
        blank=True,
        null=True,
        verbose_name="Adresse"
    )
 
    latitude = models.DecimalField(
        max_digits=9,
        decimal_places=6,
        blank=True,
        null=True,
        verbose_name="Latitude (géolocalisation)"
    )
 
    longitude = models.DecimalField(
        max_digits=9,
        decimal_places=6,
        blank=True,
        null=True,
        verbose_name="Longitude (géolocalisation)"
    )
 
    # ── Horaires ─────────────────────────────────────────────────────────────
    horaire_ouverture = models.TimeField(
        blank=True,
        null=True,
        verbose_name="Heure d'ouverture"
    )
 
    horaire_fermeture = models.TimeField(
        blank=True,
        null=True,
        verbose_name="Heure de fermeture"
    )
 
    options_livraison = models.BooleanField(
        default=False,
        verbose_name="Livraison disponible"
    )
 
    # ── Relation vers le Professionnel propriétaire ───────────────────────────
    professionnel = models.ForeignKey(
        ProfilProfessionnel,
        on_delete=models.CASCADE,
        related_name='services',
        verbose_name="Professionnel"
    )
 
    # ── Statut ───────────────────────────────────────────────────────────────
    est_actif = models.BooleanField(
        default=True,
        verbose_name="Service actif"
    )
 
    est_signale = models.BooleanField(
        default=False,
        verbose_name="Signalé pour modération"
    )
 
    # ── Timestamps ────────────────────────────────────────────────────────────
    date_creation    = models.DateTimeField(auto_now_add=True)
    date_modification = models.DateTimeField(auto_now=True)
 
    # ── Helper : note moyenne ─────────────────────────────────────────────────
    @property
    def note_moyenne(self):
        avis = self.avis.all()
        if not avis.exists():
            return None
        return round(sum(a.note for a in avis) / avis.count(), 1)
 
    def __str__(self):
        return f"{self.nom} ({self.get_type_service_display()})"
 
    class Meta:
        verbose_name = "Service"
        verbose_name_plural = "Services"
        ordering = ['-date_creation']
 
 
class PhotoService(models.Model):
    """
    Galerie de photos liée à un Service.
    Un service peut avoir plusieurs photos.
    """
 
    service = models.ForeignKey(
        Service,
        on_delete=models.CASCADE,
        related_name='photos',
        verbose_name="Service"
    )
 
    image = models.ImageField(
        upload_to='services/photos/',
        verbose_name="Image"
    )
 
    legende = models.CharField(
        max_length=200,
        blank=True,
        null=True,
        verbose_name="Légende"
    )
 
    est_principale = models.BooleanField(
        default=False,
        verbose_name="Photo principale"
    )
 
    date_ajout = models.DateTimeField(auto_now_add=True)
 
    def __str__(self):
        return f"Photo — {self.service.nom} ({'principale' if self.est_principale else 'galerie'})"
 
    class Meta:
        verbose_name = "Photo de service"
        verbose_name_plural = "Photos de services"