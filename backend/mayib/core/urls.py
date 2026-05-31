from rest_framework.routers import DefaultRouter
from .views import EvenementViewSet, NotificationViewSet

router = DefaultRouter()
router.register(r'evenements', EvenementViewSet, basename='evenement')
router.register(r'notifications', NotificationViewSet, basename='notification')
urlpatterns = router.urls


