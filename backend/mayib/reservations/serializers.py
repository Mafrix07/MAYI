from rest_framework import serializers
from .models import Reservation, PaiementAcompte, PaiementSolde
from services.serializers import ServiceSerializer

class PaiementAcompteSerializer(serializers.ModelSerializer):
    class Meta:
        model = PaiementAcompte
        fields = [
            'id', 'operateur', 'numero_telephone', 'reference_transaction', 
            'montant', 'statut_paiement', 'date_paiement', 'capture_ecran'
        ]

class PaiementSoldeSerializer(serializers.ModelSerializer):
    class Meta:
        model = PaiementSolde
        fields = ['id', 'montant', 'mode_paiement', 'reference_transaction', 'date_paiement']

class ReservationSerializer(serializers.ModelSerializer):
    service_details = ServiceSerializer(source='service', read_only=True)
    paiement_acompte = PaiementAcompteSerializer(read_only=True)
    paiement_solde = PaiementSoldeSerializer(read_only=True)
    
    # Précision décimale pour Flutter
    prix_total = serializers.DecimalField(max_digits=10, decimal_places=2, coerce_to_string=True, read_only=True)
    montant_acompte = serializers.DecimalField(max_digits=10, decimal_places=2, coerce_to_string=True, read_only=True)
    solde_restant = serializers.DecimalField(max_digits=10, decimal_places=2, coerce_to_string=True, read_only=True)

    class Meta:
        model = Reservation
        fields = [
            'id', 'service', 'service_details', 'date_debut', 'date_fin',
            'statut', 'nombre_personnes', 'message', 'prix_total',
            'montant_acompte', 'solde_restant', 'paiement_acompte', 
            'paiement_solde', 'date_creation'
        ]
        read_only_fields = ['prix_total', 'montant_acompte', 'solde_restant']

    def validate(self, data):
        date_debut = data.get('date_debut')
        date_fin = data.get('date_fin')

        if date_fin and date_debut and date_fin <= date_debut:
            raise serializers.ValidationError({
                "date_fin": "La date de fin doit être postérieure à la date de début."
            })
            
        if data.get('nombre_personnes', 1) < 1:
            raise serializers.ValidationError({
                "nombre_personnes": "Le nombre de personnes doit être au moins de 1."
            })
            
        return data
