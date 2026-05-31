from rest_framework import viewsets, permissions, filters
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework import status
from django.db.models import Avg
from django.shortcuts import get_object_or_404
from django_filters.rest_framework import DjangoFilterBackend

from .models import Service, PhotoService
from .serializers import ServiceSerializer, PhotoServiceSerializer
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

    def get_authenticators(self):
        if getattr(self, 'action', None) in ['list', 'retrieve']:
            return []
        return super().get_authenticators()

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


class PhotoServiceUploadView(APIView):
    """POST /services/{id}/photos/ — Ajoute une photo à un service."""
    permission_classes = [permissions.IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser]

    def post(self, request, service_id):
        service = get_object_or_404(Service, pk=service_id)

        # Seul le propriétaire peut ajouter des photos
        if service.professionnel.utilisateur != request.user:
            return Response(
                {'error': 'Vous n\'êtes pas propriétaire de ce service.'},
                status=status.HTTP_403_FORBIDDEN
            )

        image = request.FILES.get('image')
        if not image:
            return Response(
                {'error': 'Aucune image fournie.'},
                status=status.HTTP_400_BAD_REQUEST
            )

        est_principale = request.data.get('est_principale', 'false').lower() == 'true'

        # Si principale → retirer le flag des autres photos
        if est_principale:
            service.photos.update(est_principale=False)

        photo = PhotoService.objects.create(
            service=service,
            image=image,
            est_principale=est_principale,
        )

        return Response(
            PhotoServiceSerializer(photo, context={'request': request}).data,
            status=status.HTTP_201_CREATED
        )
