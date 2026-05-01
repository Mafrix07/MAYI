from django.db import models
from users.models import Utilisateur
from reservations.models import Reservation
# Create your models here.

class Ticket(models.Model):
    """
    Ticket de support ouvert par un utilisateur.
    Géré par l'équipe support client.
    """

    class Statut(models.TextChoices):
        OUVERT      = 'OUVERT',      'Ouvert'
        EN_COURS    = 'EN_COURS',    'En cours de traitement'
        RESOLU      = 'RESOLU',      'Résolu'
        FERME       = 'FERME',       'Fermé'

    class TypeTicket(models.TextChoices):
        REMBOURSEMENT = 'REMBOURSEMENT', 'Demande de remboursement'
        ANNULATION    = 'ANNULATION',    'Demande d\'annulation'
        PROBLEME      = 'PROBLEME',      'Problème technique'
        ACCES_COMPTE  = 'ACCES_COMPTE',  'Accès au compte'
        AUTRE         = 'AUTRE',         'Autre'

    # ── Relations ─────────────────────────────────────────────────────────────
    utilisateur = models.ForeignKey(
        Utilisateur,
        on_delete=models.CASCADE,
        related_name='tickets',
        verbose_name="Utilisateur"
    )

    assigne_a = models.ForeignKey(
        Utilisateur,
        on_delete=models.SET_NULL,
        related_name='tickets_assignes',
        blank=True,
        null=True,
        verbose_name="Assigné à (support)"
    )

    reservation = models.ForeignKey(
        Reservation,
        on_delete=models.SET_NULL,
        related_name='tickets',
        blank=True,
        null=True,
        verbose_name="Réservation concernée (optionnel)"
    )

    # ── Contenu ───────────────────────────────────────────────────────────────
    type_ticket = models.CharField(
        max_length=20,
        choices=TypeTicket.choices,
        verbose_name="Type de demande"
    )

    sujet = models.CharField(
        max_length=200,
        verbose_name="Sujet"
    )

    description = models.TextField(
        verbose_name="Description du problème"
    )

    statut = models.CharField(
        max_length=20,
        choices=Statut.choices,
        default=Statut.OUVERT,
        verbose_name="Statut"
    )

    # ── Timestamps ────────────────────────────────────────────────────────────
    date_creation     = models.DateTimeField(auto_now_add=True)
    date_modification = models.DateTimeField(auto_now=True)
    date_resolution   = models.DateTimeField(
        blank=True,
        null=True,
        verbose_name="Date de résolution"
    )

    def __str__(self):
        return f"Ticket #{self.pk} — {self.sujet} ({self.get_statut_display()})"

    class Meta:
        verbose_name = "Ticket de support"
        verbose_name_plural = "Tickets de support"
        ordering = ['-date_creation']


class MessageTicket(models.Model):
    """
    Message dans un fil de discussion d'un ticket.
    Permet les échanges entre l'utilisateur et le support.
    """

    ticket = models.ForeignKey(
        Ticket,
        on_delete=models.CASCADE,
        related_name='messages',
        verbose_name="Ticket"
    )

    auteur = models.ForeignKey(
        Utilisateur,
        on_delete=models.CASCADE,
        related_name='messages_tickets',
        verbose_name="Auteur"
    )

    contenu = models.TextField(
        verbose_name="Message"
    )

    date_envoi = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Message de {self.auteur.username} sur Ticket #{self.ticket.pk}"

    class Meta:
        verbose_name = "Message de ticket"
        verbose_name_plural = "Messages de tickets"
        ordering = ['date_envoi']
