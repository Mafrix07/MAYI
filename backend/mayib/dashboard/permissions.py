from django.contrib.auth.mixins import UserPassesTestMixin
from django.contrib.auth.decorators import user_passes_test

def staff_required(view_func):
    """
    Décorateur qui vérifie si l'utilisateur est staff ou admin.
    """
    actual_decorator = user_passes_test(
        lambda u: u.is_authenticated and (u.is_staff or u.role == 'ADMIN' or u.role == 'SUPPORT'),
        login_url='admin:login'
    )
    if view_func:
        return actual_decorator(view_func)
    return actual_decorator

class StaffRequiredMixin(UserPassesTestMixin):
    """
    Mixin pour les vues basées sur les classes (CBV).
    """
    def test_func(self):
        return self.request.user.is_authenticated and (self.request.user.is_staff or self.request.user.role == 'ADMIN' or self.request.user.role == 'SUPPORT')
