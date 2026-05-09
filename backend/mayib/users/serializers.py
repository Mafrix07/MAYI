from rest_framework import serializers
from django.contrib.auth.password_validation import validate_password
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from .models import Utilisateur, ProfilProfessionnel, ProfilTouriste

# ── AUTHENTIFICATION (Restauré) ──────────────────────────────────────────────
class MyTokenObtainPairSerializer(TokenObtainPairSerializer):
    @classmethod
    def get_token(cls, user):
        token = super().get_token(user)
        # Champs custom ajoutes dans le payload du token
        token['username'] = user.username
        token['role'] = user.role  # TOURISTE, PROFESSIONNEL, SUPPORT, ADMIN
        token['email'] = user.email
        return token


# ── INSCRIPTION (Restauré & Harmonisé) ───────────────────────────────────────
class InscriptionSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, required=True, validators=[validate_password])
    password_confirm = serializers.CharField(write_only=True, required=True)

    class Meta:
        model = Utilisateur
        fields = ('username', 'email', 'password', 'password_confirm', 'role', 'telephone', 'first_name', 'last_name')

    def validate(self, attrs):
        if attrs['password'] != attrs['password_confirm']:
            raise serializers.ValidationError({"password": "Les mots de passe ne correspondent pas."})
        return attrs

    def create(self, validated_data):
        validated_data.pop('password_confirm')
        user = Utilisateur.objects.create_user(**validated_data)
        # Le profil (ProfilTouriste ou ProfilProfessionnel) est créé
        # automatiquement via le signal post_save dans signals.py
        return user# signals.py cree le profil Touriste ou Pro automatiquement

# ── PROFILS (Version Pro) ────────────────────────────────────────────────────
class ProfilProSerializer(serializers.ModelSerializer):
    nom_entreprise = serializers.CharField(source='nom_etablissement', read_only=True)

    class Meta:
        model = ProfilProfessionnel
        fields = ['id', 'nom_entreprise', 'est_verifie', 'description_etablissement', 'adresse', 'site_web']
        read_only_fields = fields

class ProfilTouristeSerializer(serializers.ModelSerializer):
    class Meta:
        model = ProfilTouriste
        fields = ['nationalite', 'langue_preferee']

class ProfilUtilisateurSerializer(serializers.ModelSerializer):
    profil_detail = serializers.SerializerMethodField()
    reservations_actives = serializers.SerializerMethodField()

    class Meta:
        model = Utilisateur
        fields = [
            'id', 'username', 'email', 'first_name', 'last_name', 'role',
            'telephone', 'photo_profil', 'profil_detail', 'reservations_actives'
        ]

    def get_profil_detail(self, obj):
        if obj.role == 'TOURISTE':
            profil = getattr(obj, 'profil_touriste', None)
            if profil:
                return ProfilTouristeSerializer(profil).data
        elif obj.role == 'PROFESSIONNEL':
            profil = getattr(obj, 'profil_professionnel', None)
            if profil:
                return ProfilProSerializer(profil).data
        return None

    def get_reservations_actives(self, obj):
        from reservations.serializers import ReservationSerializer
        # On ne prend que les réservations qui ne sont ni annulées ni terminées
        reservations = obj.reservations.exclude(statut__in=['ANNULEE', 'TERMINEE'])
        return ReservationSerializer(reservations, many=True).data
