

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