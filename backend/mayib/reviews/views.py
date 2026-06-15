# ============================================================
# FICHIER : reviews/views.py
# DOMAINE : Avis et notations
# NOTE : unicité gérée par modèle + serializer, pas dans la vue
# NE PAS MODIFIER : reviews/serializers.py
# ============================================================

from rest_framework import viewsets, permissions, status
from rest_framework.views import APIView
from rest_framework.response import Response
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
        qs = Avis.objects.all().select_related('touriste', 'service').order_by('-date_creation')
        professionnel_id = self.request.query_params.get('professionnel_id')
        if professionnel_id:
            qs = qs.filter(service__professionnel_id=professionnel_id)
        return qs

    def get_authenticators(self):
        if getattr(self, 'action', None) in ['list', 'retrieve']:
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

class AdminReviewsListView(APIView):
    """Liste tous les avis (avec est_signale) — réservé ADMIN/SUPPORT."""
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        if request.user.role not in ['ADMIN', 'SUPPORT']:
            return Response({'error': 'Accès refusé'}, status=status.HTTP_403_FORBIDDEN)
        signale_only = request.query_params.get('signale') == 'true'
        qs = Avis.objects.all().select_related('touriste', 'service').order_by('-est_signale', '-date_creation')
        if signale_only:
            qs = qs.filter(est_signale=True)
        data = [
            {
                'id': a.id,
                'auteur': a.touriste.username,
                'service_nom': a.service.nom,
                'note': a.note,
                'commentaire': a.commentaire,
                'est_signale': a.est_signale,
                'date_creation': a.date_creation.isoformat(),
            }
            for a in qs
        ]
        return Response(data)


class AdminReviewDeleteView(APIView):
    """Supprime n'importe quel avis — réservé ADMIN/SUPPORT."""
    permission_classes = [permissions.IsAuthenticated]

    def delete(self, request, pk):
        if request.user.role not in ['ADMIN', 'SUPPORT']:
            return Response({'error': 'Accès refusé'}, status=status.HTTP_403_FORBIDDEN)
        try:
            avis = Avis.objects.get(pk=pk)
        except Avis.DoesNotExist:
            return Response({'error': 'Introuvable'}, status=status.HTTP_404_NOT_FOUND)
        avis.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)
