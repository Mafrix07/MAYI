from django.contrib.auth.models import AbstractUser
from django.db import models
 
 
class Utilisateur(AbstractUser):
    """
    Modèle utilisateur principal.
    Hérite de AbstractUser (username, email, password, first_name, last_name déjà inclus).
    """
 
    class Role(models.TextChoices):
        TOURISTE      = 'TOURISTE',      'Touriste / Résident local'
        PROFESSIONNEL = 'PROFESSIONNEL', 'Professionnel du tourisme'
        SUPPORT       = 'SUPPORT',       'Équipe support client'
        ADMIN         = 'ADMIN',         'Administrateur'
 
    role = models.CharField(
        max_length=20,
        choices=Role.choices,
        default=Role.TOURISTE,
        verbose_name="Rôle"
    )
 
    telephone = models.CharField(
        max_length=20,
        blank=True,
        null=True,
        verbose_name="Téléphone"
    )
 
    photo_profil = models.ImageField(
        upload_to='profils/',
        blank=True,
        null=True,
        verbose_name="Photo de profil"
    )
 
    date_creation = models.DateTimeField(auto_now_add=True)
    date_modification = models.DateTimeField(auto_now=True)
 
    # Helpers pour vérifier le rôle facilement
    @property
    def est_touriste(self):
        return self.role == self.Role.TOURISTE
 
    @property
    def est_professionnel(self):
        return self.role == self.Role.PROFESSIONNEL
 
    @property
    def est_support(self):
        return self.role == self.Role.SUPPORT
 
    @property
    def est_admin(self):
        return self.role == self.Role.ADMIN
 
    def __str__(self):
        return f"{self.username} ({self.get_role_display()})"
 
    class Meta:
        verbose_name = "Utilisateur"
        verbose_name_plural = "Utilisateurs"
 
 
class ProfilTouriste(models.Model):
    """
    Profil étendu pour les touristes / résidents locaux.
    Lié à Utilisateur par une relation OneToOne.
    """
 
    utilisateur = models.OneToOneField(
        Utilisateur,
        on_delete=models.CASCADE,
        related_name='profil_touriste'
    )
 
    nationalite = models.CharField(
        max_length=100,
        blank=True,
        null=True,
        verbose_name="Nationalité"
    )
 
    langue_preferee = models.CharField(
        max_length=10,
        default='fr',
        verbose_name="Langue préférée"
    )
 
    historique_navigation = models.JSONField(
        default=list,
        blank=True,
        verbose_name="Historique de navigation (IDs services consultés)"
    )
 
    def __str__(self):
        return f"Profil Touriste — {self.utilisateur.username}"
 
    class Meta:
        verbose_name = "Profil Touriste"
        verbose_name_plural = "Profils Touristes"
 
 
class ProfilProfessionnel(models.Model):
    """
    Profil étendu pour les professionnels du tourisme.
    Lié à Utilisateur par une relation OneToOne.
    """
 
    utilisateur = models.OneToOneField(
        Utilisateur,
        on_delete=models.CASCADE,
        related_name='profil_professionnel'
    )
 
    nom_etablissement = models.CharField(
        max_length=200,
        verbose_name="Nom de l'établissement"
    )
 
    description_etablissement = models.TextField(
        blank=True,
        null=True,
        verbose_name="Description de l'établissement"
    )
 
    adresse = models.CharField(
        max_length=300,
        blank=True,
        null=True,
        verbose_name="Adresse"
    )
 
    site_web = models.URLField(
        blank=True,
        null=True,
        verbose_name="Site web"
    )
 
    est_verifie = models.BooleanField(
        default=False,
        verbose_name="Compte vérifié par l'admin"
    )
 
    def __str__(self):
        return f"Profil Pro — {self.nom_etablissement} ({self.utilisateur.username})"
 
    class Meta:
        verbose_name = "Profil Professionnel"
        verbose_name_plural = "Profils Professionnels"