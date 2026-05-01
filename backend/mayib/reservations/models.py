from django.db import models
from django.core.validators import MinValueValidator, MaxValueValidator
from users.models import Utilisateur, ProfilProfessionnel
from services.models import Service
 
 
# ─────────────────────────────────────────────────────────────────────────────
# RESERVATION
# ─────────────────────────────────────────────────────────────────────────────
 
class Reservation(models.Model):
 
    class Statut(models.TextChoices):
        EN_ATTENTE          = 'EN_ATTENTE',          'En attente de paiement acompte'
        ACOMPTE_EN_VERIFICATION = 'ACOMPTE_EN_VERIFICATION', 'Acompte en vérification'
        CONFIRMEE           = 'CONFIRMEE',           'Confirmée'
        SOLDE_EN_ATTENTE    = 'SOLDE_EN_ATTENTE',    'En attente du solde'
        TERMINEE            = 'TERMINEE',            'Terminée'
        ANNULEE             = 'ANNULEE',             'Annulée'
 
    class TypeReservation(models.TextChoices):
        HEBERGEMENT = 'HEBERGEMENT', "Réservation d'hébergement"
        TABLE       = 'TABLE',       'Réservation de table'
 
    class TypeAcompte(models.TextChoices):
        POURCENTAGE  = 'POURCENTAGE',  'Pourcentage du prix total'
        MONTANT_FIXE = 'MONTANT_FIXE', 'Montant fixe en FCFA'
 
    # ── Relations ─────────────────────────────────────────────────────────────
    touriste = models.ForeignKey(
        Utilisateur,
        on_delete=models.CASCADE,
        related_name='reservations',
        verbose_name="Touriste"
    )
 
    service = models.ForeignKey(
        Service,
        on_delete=models.CASCADE,
        related_name='reservations',
        verbose_name="Service réservé"
    )
 
    # ── Détails réservation ───────────────────────────────────────────────────
    type_reservation = models.CharField(
        max_length=20,
        choices=TypeReservation.choices,
        verbose_name="Type de réservation"
    )
 
    statut = models.CharField(
        max_length=30,
        choices=Statut.choices,
        default=Statut.EN_ATTENTE,
        verbose_name="Statut"
    )
 
    date_debut = models.DateField(
        verbose_name="Date de début / arrivée"
    )
 
    date_fin = models.DateField(
        blank=True,
        null=True,
        verbose_name="Date de fin / départ (hébergement)"
    )
 
    heure_reservation = models.TimeField(
        blank=True,
        null=True,
        verbose_name="Heure de réservation (table)"
    )
 
    nombre_personnes = models.PositiveIntegerField(
        default=1,
        verbose_name="Nombre de personnes"
    )
 
    message = models.TextField(
        blank=True,
        null=True,
        verbose_name="Message ou demande spéciale"
    )
 
    # ── Prix ─────────────────────────────────────────────────────────────────
    prix_total = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        verbose_name="Prix total (FCFA)"
    )
 
    # ── Acompte — fixé par le professionnel par service ───────────────────────
    type_acompte = models.CharField(
        max_length=20,
        choices=TypeAcompte.choices,
        verbose_name="Type d'acompte"
    )
 
    valeur_acompte = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        verbose_name="Valeur acompte (% ou FCFA selon type)"
    )
 
    montant_acompte = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        verbose_name="Montant acompte calculé (FCFA)"
    )
 
    solde_restant = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        verbose_name="Solde restant à payer sur place (FCFA)"
    )
 
    solde_paye = models.BooleanField(
        default=False,
        verbose_name="Solde réglé sur place"
    )
 
    # ── Timestamps ────────────────────────────────────────────────────────────
    date_creation     = models.DateTimeField(auto_now_add=True)
    date_modification = models.DateTimeField(auto_now=True)
 
    def calculer_acompte(self):
        """
        Calcule automatiquement le montant de l'acompte
        selon le type choisi par le professionnel.
        """
        if self.type_acompte == self.TypeAcompte.POURCENTAGE:
            self.montant_acompte = self.prix_total * self.valeur_acompte / 100
        else:
            self.montant_acompte = self.valeur_acompte
 
        self.solde_restant = self.prix_total - self.montant_acompte
 
    def save(self, *args, **kwargs):
        # Calcule automatiquement l'acompte avant chaque sauvegarde
        self.calculer_acompte()
        super().save(*args, **kwargs)
 
    def __str__(self):
        return f"Réservation #{self.pk} — {self.touriste.username} → {self.service.nom} ({self.get_statut_display()})"
 
    class Meta:
        verbose_name = "Réservation"
        verbose_name_plural = "Réservations"
        ordering = ['-date_creation']
 
 
# ─────────────────────────────────────────────────────────────────────────────
# PAIEMENT ACOMPTE
# ─────────────────────────────────────────────────────────────────────────────
 
class PaiementAcompte(models.Model):
    """
    Enregistre la transaction de paiement de l'acompte par paiement mobile.
    Flooz  → vérification automatique via API
    T-Money → vérification manuelle par le professionnel
    """
 
    class Operateur(models.TextChoices):
        FLOOZ   = 'FLOOZ',   'Flooz (Moov)'
        TMONEY  = 'TMONEY',  'T-Money (Togocom)'
 
    class StatutPaiement(models.TextChoices):
        EN_ATTENTE  = 'EN_ATTENTE',  'En attente'
        EN_COURS    = 'EN_COURS',    'Vérification en cours'
        VALIDE      = 'VALIDE',      'Validé'
        REJETE      = 'REJETE',      'Rejeté'
 
    class ModèreVerification(models.TextChoices):
        AUTOMATIQUE = 'AUTOMATIQUE', 'API automatique (Flooz)'
        MANUELLE    = 'MANUELLE',    'Manuelle (T-Money)'
 
    # ── Relations ─────────────────────────────────────────────────────────────
    reservation = models.OneToOneField(
        Reservation,
        on_delete=models.CASCADE,
        related_name='paiement_acompte',
        verbose_name="Réservation"
    )
 
    # ── Infos paiement mobile ─────────────────────────────────────────────────
    operateur = models.CharField(
        max_length=10,
        choices=Operateur.choices,
        verbose_name="Opérateur mobile"
    )
 
    mode_verification = models.CharField(
        max_length=15,
        choices=ModèreVerification.choices,
        verbose_name="Mode de vérification"
    )
 
    numero_telephone = models.CharField(
        max_length=20,
        verbose_name="Numéro de téléphone utilisé"
    )
 
    reference_transaction = models.CharField(
        max_length=100,
        verbose_name="Référence / code de transaction"
    )
 
    montant = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        verbose_name="Montant payé (FCFA)"
    )
 
    statut_paiement = models.CharField(
        max_length=15,
        choices=StatutPaiement.choices,
        default=StatutPaiement.EN_ATTENTE,
        verbose_name="Statut du paiement"
    )
 
    # ── Pour vérification manuelle (T-Money) ──────────────────────────────────
    capture_ecran = models.ImageField(
        upload_to='paiements/captures/',
        blank=True,
        null=True,
        verbose_name="Capture d'écran du paiement"
    )
 
    valide_par = models.ForeignKey(
        Utilisateur,
        on_delete=models.SET_NULL,
        related_name='paiements_valides',
        blank=True,
        null=True,
        verbose_name="Validé par (professionnel)"
    )
 
    commentaire_rejet = models.TextField(
        blank=True,
        null=True,
        verbose_name="Raison du rejet (si rejeté)"
    )
 
    # ── Pour vérification automatique (Flooz) ────────────────────────────────
    reponse_api = models.JSONField(
        blank=True,
        null=True,
        verbose_name="Réponse brute de l'API Flooz"
    )
 
    # ── Timestamps ────────────────────────────────────────────────────────────
    date_paiement   = models.DateTimeField(auto_now_add=True)
    date_validation = models.DateTimeField(
        blank=True,
        null=True,
        verbose_name="Date de validation"
    )
 
    def __str__(self):
        return f"Acompte Réservation #{self.reservation.pk} — {self.operateur} — {self.get_statut_paiement_display()}"
 
    class Meta:
        verbose_name = "Paiement acompte"
        verbose_name_plural = "Paiements acomptes"
 
 
# ─────────────────────────────────────────────────────────────────────────────
# PAIEMENT SOLDE
# ─────────────────────────────────────────────────────────────────────────────
 
class PaiementSolde(models.Model):
    """
    Enregistre le règlement du solde restant, effectué sur place
    après la prestation. Confirmé par le professionnel.
    """
 
    class ModePaiement(models.TextChoices):
        ESPECES = 'ESPECES', 'Espèces'
        FLOOZ   = 'FLOOZ',   'Flooz (Moov)'
        TMONEY  = 'TMONEY',  'T-Money (Togocom)'
 
    # ── Relations ─────────────────────────────────────────────────────────────
    reservation = models.OneToOneField(
        Reservation,
        on_delete=models.CASCADE,
        related_name='paiement_solde',
        verbose_name="Réservation"
    )
 
    confirme_par = models.ForeignKey(
        Utilisateur,
        on_delete=models.SET_NULL,
        related_name='soldes_confirmes',
        null=True,
        verbose_name="Confirmé par (professionnel)"
    )
 
    # ── Détails ───────────────────────────────────────────────────────────────
    montant = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        verbose_name="Montant solde payé (FCFA)"
    )
 
    mode_paiement = models.CharField(
        max_length=10,
        choices=ModePaiement.choices,
        verbose_name="Mode de paiement du solde"
    )
 
    reference_transaction = models.CharField(
        max_length=100,
        blank=True,
        null=True,
        verbose_name="Référence transaction (si mobile)"
    )
 
    notes = models.TextField(
        blank=True,
        null=True,
        verbose_name="Notes"
    )
 
    date_paiement = models.DateTimeField(auto_now_add=True)
 
    def __str__(self):
        return f"Solde Réservation #{self.reservation.pk} — {self.montant} FCFA"
 
    class Meta:
        verbose_name = "Paiement solde"
        verbose_name_plural = "Paiements soldes"