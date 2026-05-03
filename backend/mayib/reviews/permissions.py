from rest_framework import permissions

class IsAuteurOrReadOnly(permissions.BasePermission):
    """
    Tout le monde peut lire les avis.
    Seul l'auteur (touriste) peut modifier/supprimer son propre avis.
    """
    def has_object_permission(self, request, view, obj):
        if request.method in permissions.SAFE_METHODS:
            return True
        return obj.touriste == request.user
