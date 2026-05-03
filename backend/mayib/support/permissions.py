from rest_framework import permissions

class IsTicketOwnerOrSupport(permissions.BasePermission):
    """
    - L'utilisateur qui a créé le ticket peut le voir et y répondre.
    - Le support et l'admin peuvent tout voir et gérer.
    """
    def has_object_permission(self, request, view, obj):
        user = request.user
        if not (user and user.is_authenticated):
            return False
            
        if user.role in ['SUPPORT', 'ADMIN']:
            return True
            
        return obj.utilisateur == user
