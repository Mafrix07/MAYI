from django.db.models.signals import post_save
from django.dispatch import receiver
from .models import Utilisateur, ProfilTouriste, ProfilProfessionnel


@receiver(post_save, sender=Utilisateur)
def creer_profil_utilisateur(sender, instance, created, **kwargs):
    """
    Crée automatiquement le bon profil selon le rôle
    dès qu'un nouvel utilisateur est enregistré.
    """
    if not created:
        return

    if instance.role == Utilisateur.Role.TOURISTE:
        ProfilTouriste.objects.create(utilisateur=instance)

    elif instance.role == Utilisateur.Role.PROFESSIONNEL:
        ProfilProfessionnel.objects.create(
            utilisateur=instance,
            nom_etablissement=""
        )
    # Admin et Support n'ont pas de profil étendu