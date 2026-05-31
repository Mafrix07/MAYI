# ============================================================
# FICHIER : reviews/views.py
# DOMAINE : Avis et notations
# NOTE : unicité gérée par modèle + serializer, pas dans la vue
# NE PAS MODIFIER : reviews/serializers.py
# ============================================================

from rest_framework import viewsets, permissions
from .models import Avis
from .serializers import AvisSerializer
from users.permissions import IsTouriste
from django_filters.rest_framework import DjangoFilterBackend

class IsOwnerAvis(permissions.BasePermission):
    """
    Vérifie que l'utilisateur est l'auteur de l'avis.
    """
    def has_object_permission(self, request, view, obj):
        if request.method in permissions.SAFE_METHODS:
            return True
        return obj.touriste == request.user

class AvisViewSet(viewsets.ModelViewSet):
    """
    ViewSet pour la gestion des avis sur les services.
    Lecture publique, création réservée aux touristes, modification à l'auteur.
    """
    serializer_class = AvisSerializer
    filter_backends = [DjangoFilterBackend]
    filterset_fields = ['service']


    def get_queryset(self):
        """
        Récupère tous les avis avec les informations liées du touriste et du service.
        """
        return Avis.objects.all().select_related(
            'touriste', 'service'
        ).order_by('-date_creation')

    def get_authenticators(self):
        if self.action in ['list', 'retrieve']:
            return []
        return super().get_authenticators()

    def get_permissions(self):
        if self.action in ['list', 'retrieve']:
            return [permissions.AllowAny()]
        elif self.action == 'create':
            return [permissions.IsAuthenticated(), IsTouriste()]
        elif self.action in ['update', 'partial_update', 'destroy']:
            return [permissions.IsAuthenticated(), IsOwnerAvis()]
        return super().get_permissions()

    def perform_create(self, serializer):
        """
        Associe automatiquement l'utilisateur connecté comme auteur de l'avis.
        """
        serializer.save(touriste=self.request.user)

# Résumé de fin de phase :
# ✓ Créé : AvisViewSet, IsOwnerAvis
# ✓ Importé depuis l'existant : Avis, AvisSerializer, IsTouriste
# ✓ Reste à faire : Phase 5 (core/views.py)
