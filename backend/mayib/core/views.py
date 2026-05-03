# ============================================================
# FICHIER : core/views.py
# DOMAINE : Données transversales
# NE PAS MODIFIER : core/serializers.py, core/models.py
# ============================================================

from rest_framework import viewsets, permissions, filters
from django_filters.rest_framework import DjangoFilterBackend
from .models import Evenement
from .serializers import EvenementSerializer

class EvenementViewSet(viewsets.ReadOnlyModelViewSet):
    """
    ViewSet en lecture seule pour le calendrier des événements.
    Accessible publiquement pour consultation.
    """
    queryset = Evenement.objects.all().select_related('organisateur')
    serializer_class = EvenementSerializer
    permission_classes = [permissions.AllowAny]
    
    filter_backends = [DjangoFilterBackend, filters.SearchFilter]
    
    # Champs de filtrage exact (type d'événement)
    filterset_fields = ['type_evenement', 'est_actif']
    
    # Champs de recherche textuelle
    search_fields = ['titre', 'description', 'lieu']

# Résumé de fin de phase :
# ✓ Créé : EvenementViewSet
# ✓ Importé depuis l'existant : Evenement, EvenementSerializer
# ✓ Reste à faire : Phase 6 (URLs et Configuration)
