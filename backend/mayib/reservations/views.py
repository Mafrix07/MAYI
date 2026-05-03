# ============================================================
# FICHIER : reservations/views.py
# DOMAINE : Logique transactionnelle
# CHAMPS FINANCIERS : prix_total, montant_acompte, solde_restant
# RELATED_NAMES UTILISÉS : reservations
# NE PAS MODIFIER : reservations/serializers.py
# ============================================================

from rest_framework import viewsets, permissions, status
from rest_framework.exceptions import PermissionDenied
from rest_framework.response import Response

from .models import Reservation
from .serializers import ReservationSerializer
from users.permissions import IsTouriste, IsSupportOrAdmin

class ReservationViewSet(viewsets.ModelViewSet):
    """
    ViewSet pour la gestion des réservations.
    Les touristes créent, les pros et touristes consultent et mettent à jour le statut.
    """
    serializer_class = ReservationSerializer
    http_method_names = ['get', 'post', 'patch', 'head', 'options']

    def get_queryset(self):
        """
        Filtrage des réservations selon le rôle de l'utilisateur.
        """
        user = self.request.user
        if not user.is_authenticated:
            return Reservation.objects.none()

        if user.role == 'TOURISTE':
            # Utilise le related_name 'reservations' de Utilisateur -> Reservation
            return Reservation.objects.filter(
                touriste=user
            ).select_related('service', 'touriste')
        
        elif user.role == 'PROFESSIONNEL':
            # Accès via le profil professionnel de l'utilisateur
            return Reservation.objects.filter(
                service__professionnel__utilisateur=user
            ).select_related('service', 'touriste')
        
        else:
            # ADMIN ou SUPPORT
            return Reservation.objects.all().select_related('service', 'touriste')

    def get_permissions(self):
        """
        Permissions dynamiques selon l'action.
        """
        if self.action in ['list', 'retrieve']:
            return [permissions.IsAuthenticated()]
        elif self.action == 'create':
            return [permissions.IsAuthenticated(), IsTouriste()]
        elif self.action == 'partial_update':
            return [permissions.IsAuthenticated()]
        return [permissions.IsAuthenticated(), IsSupportOrAdmin()]

    def perform_create(self, serializer):
        """
        Attache le touriste (Utilisateur) à la réservation.
        """
        serializer.save(touriste=self.request.user)

    def partial_update(self, request, *args, **kwargs):
        """
        Logique métier pour la mise à jour partielle (PATCH).
        Seul le statut peut être modifié.
        """
        instance = self.get_object()
        
        # Vérification 1 : Seul le champ 'statut' est autorisé
        allowed_fields = {'statut'}
        provided_fields = set(request.data.keys())
        if not provided_fields.issubset(allowed_fields):
            raise PermissionDenied(
                "Seul le champ 'statut' peut être modifié via cette interface."
            )

        # Vérification 2 : Permission d'accès
        # Un touriste peut modifier sa propre réservation (ex: annulation)
        # Un professionnel peut modifier les réservations de ses services
        is_touriste_owner = (instance.touriste == request.user)
        is_pro_owner = (instance.service.professionnel.utilisateur == request.user)
        is_staff = request.user.role in ['ADMIN', 'SUPPORT']

        if not (is_touriste_owner or is_pro_owner or is_staff):
            raise PermissionDenied(
                "Vous n'avez pas la permission de modifier cette réservation."
            )

        return super().partial_update(request, *args, **kwargs)

# Résumé de fin de phase :
# ✓ Créé : ReservationViewSet
# ✓ Importé depuis l'existant : Reservation, ReservationSerializer, IsTouriste, IsSupportOrAdmin
# ✓ Reste à faire : Phase 4 (reviews/views.py)
