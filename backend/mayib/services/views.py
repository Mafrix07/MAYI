from rest_framework import viewsets, permissions, filters
from django.db.models import Avg
from django_filters.rest_framework import DjangoFilterBackend

from .models import Service
from .serializers import ServiceSerializer
from .filters import ServiceFilter
from users.permissions import IsProfessionnel

class IsOwnerService(permissions.BasePermission):
    def has_object_permission(self, request, view, obj):
        if request.method in permissions.SAFE_METHODS:
            return True
        return obj.professionnel.utilisateur == request.user

class ServiceViewSet(viewsets.ModelViewSet):
    serializer_class = ServiceSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_class = ServiceFilter
    search_fields = ['nom', 'description', 'adresse']
    ordering_fields = ['prix', 'api_note_moyenne', 'date_creation']
    ordering = ['-date_creation']

    def get_queryset(self):
        queryset = Service.objects.all()
        queryset = queryset.annotate(
            api_note_moyenne=Avg('avis__note')
        ).select_related(
            'professionnel__utilisateur'
        ).prefetch_related(
            'photos'
        )
        return queryset

    def get_permissions(self):
        if self.action in ['list', 'retrieve']:
            return [permissions.AllowAny()]
        elif self.action == 'create':
            return [permissions.IsAuthenticated(), IsProfessionnel()]
        elif self.action in ['update', 'partial_update', 'destroy']:
            return [permissions.IsAuthenticated(), IsOwnerService()]
        return super().get_permissions()

    def perform_create(self, serializer):
        serializer.save(
            professionnel=self.request.user.profil_professionnel
        )
