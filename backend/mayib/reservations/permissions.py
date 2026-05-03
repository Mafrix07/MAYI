from rest_framework import permissions

class IsReservationOwnerOrServiceOwner(permissions.BasePermission):
    """
    - Le touriste peut voir/annuler sa propre réservation.
    - Le professionnel peut voir les réservations liées à ses services.
    - L'admin/support peut tout voir.
    """
    def has_object_permission(self, request, view, obj):
        user = request.user
        if not (user and user.is_authenticated):
            return False

        if user.role in ['ADMIN', 'SUPPORT']:
            return True

        # Le touriste est lié directement au modèle Reservation (via ForeignKey vers Utilisateur)
        if obj.touriste == user:
            return True

        # Le professionnel est lié via le service
        if obj.service.professionnel.utilisateur == user:
            return True

        return False
