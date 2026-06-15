"""
URL configuration for mayib project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/5.2/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path, include
from rest_framework_simplejwt.views import TokenRefreshView
from users.views import MyTokenObtainPairView, InscriptionView, MonProfilView, ProfilePhotoView, DashboardCodeView, AdminStatsView, AdminUsersListView, AdminUserToggleView
from services.views import AdminServiceToggleView
from reviews.views import AdminReviewsListView, AdminReviewDeleteView
from drf_spectacular.views import SpectacularAPIView, SpectacularRedocView, SpectacularSwaggerView
from django.conf import settings
from django.conf.urls.static import static

urlpatterns = [
    path('admin/', admin.site.urls),

    # Auth
    path('api/auth/login/',    MyTokenObtainPairView.as_view(), name='login'),
    path('api/auth/refresh/',  TokenRefreshView.as_view(),      name='token_refresh'),
    path('api/auth/register/', InscriptionView.as_view(),   name='inscription'),
    path('api/', include('support.urls')), 

    # Profil
    path('api/auth/me/',       MonProfilView.as_view(),         name='mon_profil'),
    path('api/auth/me/photo/',       ProfilePhotoView.as_view(),   name='utilisateur-photo'),
    path('api/auth/dashboard-code/', DashboardCodeView.as_view(), name='dashboard-code'),
    path('api/admin/stats/',                    AdminStatsView.as_view(),       name='admin-stats'),
    path('api/admin/users/',                    AdminUsersListView.as_view(),    name='admin-users'),
    path('api/admin/users/<int:pk>/toggle/',    AdminUserToggleView.as_view(),   name='admin-user-toggle'),
    path('api/admin/services/<int:pk>/toggle/', AdminServiceToggleView.as_view(), name='admin-service-toggle'),
    path('api/admin/reviews/',                  AdminReviewsListView.as_view(),  name='admin-reviews'),
    path('api/admin/reviews/<int:pk>/',         AdminReviewDeleteView.as_view(), name='admin-review-delete'),

    # Apps
    path('api/', include('services.urls')),
    path('api/', include('reservations.urls')),
    path('api/', include('reviews.urls')),
    path('api/', include('core.urls')),
    path('dashboard/', include('dashboard.urls')),

    # Documentation
    path('api/schema/', SpectacularAPIView.as_view(), name='schema'),
    path('api/docs/', SpectacularSwaggerView.as_view(url_name='schema'), name='swagger-ui'),
    path('api/redoc/', SpectacularRedocView.as_view(url_name='schema'), name='redoc'),
]

# Servir les fichiers media en dev ET en prod (Render n'a pas de CDN configuré)
urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)