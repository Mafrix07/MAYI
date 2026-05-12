from django.urls import path
from . import views

app_name = 'dashboard'

urlpatterns = [
    # Main Dashboard
    path('', views.index, name='index'),

    # Users Management
    path('users/', views.user_list, name='user_list'),
    path('users/<int:pk>/', views.user_detail, name='user_detail'),
    path('users/<int:pk>/toggle/', views.user_toggle_status, name='user_toggle_status'),

    # Services Management
    path('services/', views.service_list, name='service_list'),
    path('services/<int:pk>/', views.service_detail, name='service_detail'),
    path('services/<int:pk>/toggle/', views.service_toggle_status, name='service_toggle_status'),

    # Reservations Management
    path('reservations/', views.reservation_list, name='reservation_list'),
    path('reservations/<int:pk>/', views.reservation_detail, name='reservation_detail'),
    path('reservations/<int:pk>/status/', views.reservation_change_status, name='reservation_change_status'),
    path('reservations/export/', views.reservation_export_csv, name='reservation_export_csv'),

    # Reviews Moderation
    path('reviews/', views.review_list, name='review_list'),
    path('reviews/<int:pk>/approve/', views.review_approve, name='review_approve'),
    path('reviews/<int:pk>/delete/', views.review_delete, name='review_delete'),

    # Support Tickets
    path('support/', views.support_list, name='support_list'),
    path('support/<int:pk>/', views.support_detail, name='support_detail'),
    path('support/<int:pk>/status/', views.support_change_status, name='support_change_status'),
]
