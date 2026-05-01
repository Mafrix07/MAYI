from django.db import models
from services.models import Service
from users.models import Utilisateur, ProfilProfessionnel
from django.core.validators import MinValueValidator, MaxValueValidator
# Create your models here.


class Avis(models.Model):
    """
    Avis laissé par un touriste sur un service.
    Note de 1 à 5 + commentaire.
    """

    # ── Relations ─────────────────────────────────────────────────────────────
    touriste = models.ForeignKey(
        Utilisateur,
        on_delete=models.CASCADE,
        related_name='avis',
        verbose_name="Touriste"
    )

    service = models.ForeignKey(
        Service,
        on_delete=models.CASCADE,
        related_name='avis',
        verbose_name="Service évalué"
    )

    # ── Contenu ───────────────────────────────────────────────────────────────
    note = models.PositiveSmallIntegerField(
        validators=[MinValueValidator(1), MaxValueValidator(5)],
        verbose_name="Note (1 à 5)"
    )

    commentaire = models.TextField(
        blank=True,
        null=True,
        verbose_name="Commentaire"
    )

    est_signale = models.BooleanField(
        default=False,
        verbose_name="Signalé pour modération"
    )

    # ── Timestamps ────────────────────────────────────────────────────────────
    date_creation     = models.DateTimeField(auto_now_add=True)
    date_modification = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"Avis de {self.touriste.username} sur {self.service.nom} — {self.note}/5"

    class Meta:
        verbose_name = "Avis"
        verbose_name_plural = "Avis"
        ordering = ['-date_creation']
        # Un touriste ne peut laisser qu'un seul avis par service
        unique_together = ('touriste', 'service')
