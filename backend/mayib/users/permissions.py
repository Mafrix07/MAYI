from rest_framework import permissions

class IsTouriste(permissions.BasePermission):
    """Vérifie si l'utilisateur a le rôle TOURISTE."""
    def has_permission(self, request, view):
        return bool(request.user and request.user.is_authenticated and request.user.role == 'TOURISTE')

class IsProfessionnel(permissions.BasePermission):
    """Vérifie si l'utilisateur a le rôle PROFESSIONNEL."""
    def has_permission(self, request, view):
        return bool(request.user and request.user.is_authenticated and request.user.role == 'PROFESSIONNEL')

class IsSupport(permissions.BasePermission):
    """Vérifie si l'utilisateur a le rôle SUPPORT."""
    def has_permission(self, request, view):
        return bool(request.user and request.user.is_authenticated and request.user.role == 'SUPPORT')

class IsAdmin(permissions.BasePermission):
    """Vérifie si l'utilisateur est un ADMIN."""
    def has_permission(self, request, view):
        return bool(request.user and request.user.is_authenticated and request.user.role == 'ADMIN')

class IsSupportOrAdmin(permissions.BasePermission):
    """Vérifie si l'utilisateur est SUPPORT ou ADMIN."""
    def has_permission(self, request, view):
        if not (request.user and request.user.is_authenticated):
            return False
        return request.user.role in ['SUPPORT', 'ADMIN']
