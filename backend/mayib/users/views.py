

import secrets
from django.core.cache import cache
from django.utils import timezone
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status, permissions
from rest_framework_simplejwt.views import TokenObtainPairView
from rest_framework.permissions import IsAuthenticated
from rest_framework.parsers import MultiPartParser, FormParser
from .serializers import InscriptionSerializer, ProfilUtilisateurSerializer, MyTokenObtainPairSerializer


class MyTokenObtainPairView(TokenObtainPairView):
    serializer_class = MyTokenObtainPairSerializer


class InscriptionView(APIView):
    """Inscription de nouveaux utilisateurs (Touristes ou Pros)"""
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        serializer = InscriptionSerializer(data=request.data, context= {'request': request})
        if serializer.is_valid():
            user = serializer.save()
            return Response({
                "success": True,
                "message": "Compte créé avec succès.",
                "user": ProfilUtilisateurSerializer(user, context= {'request': request} ).data
            }, status=status.HTTP_201_CREATED)
        return Response({
            "success": False,
            "errors": serializer.errors
        }, status=status.HTTP_400_BAD_REQUEST)


class MonProfilView(APIView):
    """Gestion du profil utilisateur connecté"""
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        return Response(ProfilUtilisateurSerializer(request.user, context={'request': request}).data)

    def patch(self, request):
        serializer = ProfilUtilisateurSerializer(request.user, data=request.data, partial=True,context={'request': request})
        if serializer.is_valid():
            serializer.save()
            return Response({
                "success": True,
                "message": "Profil mis à jour.",
                "user": serializer.data
            })
        return Response({
            "success": False,
            "errors": serializer.errors
        }, status=status.HTTP_400_BAD_REQUEST)


class ProfilePhotoView(APIView):
    """
    Vue pour gérer l'upload de la photo de profil.
    """
    permission_classes = [IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser]

    def post(self, request, *args, **kwargs):
        utilisateur = request.user

        # Le champ 'photo_profil' doit correspondre au fieldName envoyé par Flutter
        if 'photo_profil' in request.FILES:
            utilisateur.photo_profil = request.FILES['photo_profil']
            utilisateur.save()

            # On retourne l'URL de l'image pour que Flutter puisse l'afficher
            return Response({
                "message": "Photo mise à jour avec succès",
                "photo_url": request.build_absolute_uri(utilisateur.photo_profil.url)
            }, status=status.HTTP_200_OK)

        return Response(
            {"error": "Aucun fichier photo_profil reçu"},
            status=status.HTTP_400_BAD_REQUEST
        )


class DashboardCodeView(APIView):
    """Génère un code usage unique (60s) pour auto-login dashboard sans JWT dans l'URL."""
    permission_classes = [IsAuthenticated]

    def post(self, request):
        if request.user.role not in ['SUPPORT', 'ADMIN']:
            return Response({'error': 'Accès refusé'}, status=status.HTTP_403_FORBIDDEN)
        code = secrets.token_urlsafe(32)
        cache.set(f'dashboard_code_{code}', request.user.pk, timeout=60)
        return Response({'code': code})


class AdminStatsView(APIView):
    """KPIs pour l'AdminScreen Flutter — réservé ADMIN et SUPPORT."""
    permission_classes = [IsAuthenticated]

    def get(self, request):
        if request.user.role not in ['ADMIN', 'SUPPORT']:
            return Response({'error': 'Accès refusé'}, status=status.HTTP_403_FORBIDDEN)

        from services.models import Service
        from reservations.models import Reservation
        from reviews.models import Avis

        month_start = timezone.now().replace(day=1, hour=0, minute=0, second=0, microsecond=0)

        return Response({
            'total_users': self.__class__._count_users(),
            'total_services': Service.objects.filter(est_actif=True).count(),
            'reservations_ce_mois': Reservation.objects.filter(date_creation__gte=month_start).count(),
            'avis_signales': Avis.objects.filter(est_signale=True).count(),
            'services_signales': Service.objects.filter(est_signale=True).count(),
        })

    @staticmethod
    def _count_users():
        from .models import Utilisateur
        return Utilisateur.objects.count()


class AdminUsersListView(APIView):
    """Liste tous les utilisateurs — réservé ADMIN/SUPPORT."""
    permission_classes = [IsAuthenticated]

    def get(self, request):
        if request.user.role not in ['ADMIN', 'SUPPORT']:
            return Response({'error': 'Accès refusé'}, status=status.HTTP_403_FORBIDDEN)
        from .models import Utilisateur
        role = request.query_params.get('role')
        qs = Utilisateur.objects.all().order_by('-date_creation')
        if role:
            qs = qs.filter(role=role)
        data = [
            {
                'id': u.id,
                'username': u.username,
                'email': u.email,
                'first_name': u.first_name,
                'last_name': u.last_name,
                'role': u.role,
                'is_active': u.is_active,
                'date_creation': u.date_creation.isoformat(),
            }
            for u in qs
        ]
        return Response(data)


class AdminUserToggleView(APIView):
    """Active/désactive un utilisateur — réservé ADMIN/SUPPORT."""
    permission_classes = [IsAuthenticated]

    def patch(self, request, pk):
        if request.user.role not in ['ADMIN', 'SUPPORT']:
            return Response({'error': 'Accès refusé'}, status=status.HTTP_403_FORBIDDEN)
        from .models import Utilisateur
        try:
            user_obj = Utilisateur.objects.get(pk=pk)
        except Utilisateur.DoesNotExist:
            return Response({'error': 'Introuvable'}, status=status.HTTP_404_NOT_FOUND)
        user_obj.is_active = not user_obj.is_active
        user_obj.save()
        return Response({'id': user_obj.id, 'is_active': user_obj.is_active})