from django.urls import path
from rest_framework.routers import DefaultRouter
from .views import ServiceViewSet, PhotoServiceUploadView

router = DefaultRouter()
router.register(r'services', ServiceViewSet, basename='service')

urlpatterns = router.urls + [
    path('services/<int:service_id>/photos/', PhotoServiceUploadView.as_view(), name='service-photo-upload'),
]
