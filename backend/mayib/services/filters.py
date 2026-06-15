# ============================================================
# FICHIER : services/filters.py
# DOMAINE : Filtrage du catalogue
# RELATED_NAME UTILISÉ : avis
# ============================================================

import django_filters
from django.db.models import Avg
from .models import Service

class ServiceFilter(django_filters.FilterSet):
    """
    Filtres pour le catalogue des services.
    Permet de filtrer par type, localisation, prix et note.
    """
    
    # Filtre par type (HEBERGEMENT, SNACK, ACTIVITE, TRANSPORT)
    type_service = django_filters.ChoiceFilter(
        choices=Service.TypeService.choices
    )

    # Localisation (recherche partielle sur l'adresse)
    localisation = django_filters.CharFilter(
        field_name='adresse', 
        lookup_expr='icontains',
        label='Localisation (adresse)'
    )

    # Plage de prix
    prix_min = django_filters.NumberFilter(
        field_name='prix', 
        lookup_expr='gte',
        label='Prix minimum'
    )
    prix_max = django_filters.NumberFilter(
        field_name='prix', 
        lookup_expr='lte',
        label='Prix maximum'
    )

    # Note moyenne minimale
    note_min = django_filters.NumberFilter(
        method='filter_note_min',
        label='Note minimale (1-5)'
    )

    professionnel = django_filters.NumberFilter(field_name='professionnel__id')

    class Meta:
        model = Service
        fields = ['type_service', 'localisation', 'prix_min', 'prix_max', 'note_min', 'professionnel']

    def filter_note_min(self, queryset, name, value):
        """
        Filtre les services ayant une note moyenne supérieure ou égale à la valeur.
        Utilise le related_name 'avis' défini dans reviews/models.py.
        """
        return queryset.annotate(
            note_moy=Avg('avis__note')
        ).filter(note_moy__gte=value)

# Résumé de fin de phase :
# ✓ Créé : ServiceFilter
# ✓ Importé depuis l'existant : Service
# ✓ Reste à faire : Mettre à jour services/views.py pour utiliser ce filtre
