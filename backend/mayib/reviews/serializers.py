from rest_framework import serializers
from .models import Avis

class AvisSerializer(serializers.ModelSerializer):
    auteur = serializers.ReadOnlyField(source='touriste.username')

    class Meta:
        model = Avis
        fields = ['id', 'service', 'auteur', 'note', 'commentaire', 'date_creation']

    def validate_note(self, value):
        if not (1 <= value <= 5):
            raise serializers.ValidationError("La note doit être comprise entre 1 et 5.")
        return value

    def validate(self, data):
        request = self.context.get('request')
        if request and request.method == 'POST':
            service = data.get('service')
            user = request.user
            if Avis.objects.filter(touriste=user, service=service).exists():
                raise serializers.ValidationError("Vous avez déjà laissé un avis pour ce service.")
        return data
