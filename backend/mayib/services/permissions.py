from rest_framework import permissions

class IsOwnerService(permissions.BasePermission):
    """
    Vérifie que l'utilisateur est le propriétaire du service 
    (via son profil professionnel).
    """
    def has_object_permission(self, request, view, obj):
        if not (request.user and request.user.is_authenticated):
            return False
        # SAFE_METHODS (GET, HEAD, OPTIONS) sont gérées au niveau du ViewSet (AllowAny)
        # Ici on vérifie la propriété pour modification/suppression
        return obj.professionnel.utilisateur == request.user
