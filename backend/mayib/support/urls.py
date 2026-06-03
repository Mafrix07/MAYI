from rest_framework.routers import DefaultRouter
from .views import TicketViewSet, MessageTicketViewSet

router = DefaultRouter()
router.register(r'tickets', TicketViewSet, basename='ticket')
router.register(r'messages-tickets', MessageTicketViewSet, basename='message-ticket')
urlpatterns = router.urls