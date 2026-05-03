from rest_framework import serializers
from .models import Service, PhotoService
from users.models import ProfilProfessionnel
from users.serializers import ProfilProSerializer

class PhotoServiceSerializer(serializers.ModelSerializer):
    class Meta:
        model = PhotoService
        fields = ['id', 'image', 'legende', 'est_principale']

class ServiceSerializer(serializers.ModelSerializer):
    professionnel = ProfilProSerializer(read_only=True)
    professionnel_id = serializers.PrimaryKeyRelatedField(
        queryset=ProfilProfessionnel.objects.all(),
        source='professionnel',
        write_only=True
    )
    # Note moyenne avec une décimale pour l'affichage UI (annotée dans le ViewSet)
    note_moyenne = serializers.FloatField(read_only=True) 
    photos = PhotoServiceSerializer(many=True, read_only=True)
    photo_principale = serializers.SerializerMethodField()
    
    # Précision décimale pour Flutter
    prix = serializers.DecimalField(max_digits=10, decimal_places=2, coerce_to_string=True)

    class Meta:
        model = Service
        fields = [
            'id', 'nom', 'description', 'type_service', 'prix', 'adresse',
            'latitude', 'longitude', 'horaire_ouverture', 'horaire_fermeture',
            'professionnel', 'professionnel_id', 'note_moyenne', 'photos',
            'photo_principale', 'date_creation'
        ]

    def get_photo_principale(self, obj):
        # On essaie d'abord de récupérer la photo marquée comme principale
        # Sinon on prend la première de la galerie
        photo = obj.photos.filter(est_principale=True).first()
        if not photo:
            photo = obj.photos.first()
        
        if photo:
            return PhotoServiceSerializer(photo, context=self.context).data
        return None
