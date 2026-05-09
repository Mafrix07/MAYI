# ============================================================
# FICHIER : services/views.py
# DOMAINE : Catalogue des services touristiques
# IMPORTS : ServiceSerializer (existant), IsProfessionnel (existant)
# RELATED_NAMES UTILISÉS : services, avis, profil_professionnel
# NE PAS MODIFIER : services/serializers.py, users/permissions.py
# ============================================================

from rest_framework import viewsets, permissions, filters
from django.db.models import Avg
from django_filters.rest_framework import DjangoFilterBackend

from .models import Service
from .serializers import ServiceSerializer
from .filters import ServiceFilter
from users.permissions import IsProfessionnel

# Permission locale pour vérifier le propriétaire du service
class IsOwnerService(permissions.BasePermission):
    """
    Vérifie que l'utilisateur est le professionnel propriétaire du service.
    """
    def has_object_permission(self, request, view, obj):
        if request.method in permissions.SAFE_METHODS:
            return True
        return obj.professionnel.utilisateur == request.user

class ServiceViewSet(viewsets.ModelViewSet):
    """
    ViewSet pour la gestion du catalogue des services.
    Accessible en lecture à tous, modification réservée aux professionnels propriétaires.
    """
    serializer_class = ServiceSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_class = ServiceFilter
    
    search_fields = ['nom', 'description', 'adresse']
    ordering_fields = ['prix', 'note_moyenne', 'date_creation']
    ordering = ['-date_creation']

    def get_queryset(self):
        """
        Optimisation : select_related pour le professionnel et utilisateur,
        et annotation de la note moyenne basée sur le related_name 'avis'.
        """
        queryset = Service.objects.all()
        queryset = queryset.annotate(
            note_moyenne=Avg('avis__note')
        ).select_related(
            'professionnel__utilisateur'
        ).prefetch_related(
            'photos'
        )
        return queryset

    def get_permissions(self):
        """
        Règles de permissions selon l'action.
        """
        if self.action in ['list', 'retrieve']:
            return [permissions.AllowAny()]
        elif self.action == 'create':
            return [permissions.IsAuthenticated(), IsProfessionnel()]
        elif self.action in ['update', 'partial_update', 'destroy']:
            return [permissions.IsAuthenticated(), IsOwnerService()]
        return super().get_permissions()

    def perform_create(self, serializer):
        """
        Attache automatiquement le profil professionnel de l'utilisateur créateur.
        """
        serializer.save(
            professionnel=self.request.user.profil_professionnel
        )

# Résumé de fin de phase :
# ✓ Créé : ServiceViewSet, IsOwnerService
# ✓ Importé depuis l'existant : Service, ServiceSerializer, IsProfessionnel
# ✓ Reste à faire : Phase 2 (services/filters.py)
