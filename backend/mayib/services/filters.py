from django_filters import rest_framework as filters
from django.db.models import Avg
from .models import Service

class ServiceFilter(filters.FilterSet):
    """
    Filtres personnalisés pour la recherche de services.
    Permet de filtrer par type, prix, adresse (localisation) et note moyenne.
    """
    prix_min = filters.NumberFilter(field_name="prix", lookup_expr='gte')
    prix_max = filters.NumberFilter(field_name="prix", lookup_expr='lte')
    
    # On utilise 'adresse' pour la recherche de localisation (ville/quartier)
    # car le champ 'localisation' n'est pas présent dans le modèle actuel.
    localisation = filters.CharFilter(field_name="adresse", lookup_expr='icontains')
    
    note_min = filters.NumberFilter(method='filter_by_note_min')

    class Meta:
        model = Service
        fields = ['type_service', 'prix_min', 'prix_max', 'localisation']

    def filter_by_note_min(self, queryset, name, value):
        """
        Filtre les services ayant une note moyenne supérieure ou égale à 'value'.
        L'annotation est déjà faite dans le ViewSet, mais on s'assure de sa présence ici.
        """
        return queryset.annotate(avg_rating=Avg('avis__note')).filter(avg_rating__gte=value)
