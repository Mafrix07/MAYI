from rest_framework import serializers
from django.contrib.auth.password_validation import validate_password
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from .models import Utilisateur, ProfilProfessionnel, ProfilTouriste

class MyTokenObtainPairSerializer(TokenObtainPairSerializer):
    def validate(self, attrs):
        login = attrs.get('username', '').strip()
        if '@' in login:
            user = Utilisateur.objects.filter(email__iexact=login).first()
            if user:
                attrs['username'] = user.username
            else:
                raise serializers.ValidationError(
                    {'detail': 'Identifiants incorrects. Vérifiez votre email et mot de passe.'}
                )
        return super().validate(attrs)

    @classmethod
    def get_token(cls, user):
        token = super().get_token(user)
        token['username'] = user.username
        token['role'] = user.role
        token['email'] = user.email
        return token

class InscriptionSerializer(serializers.ModelSerializer):
    password         = serializers.CharField(write_only=True, required=True, validators=[validate_password])
    password_confirm = serializers.CharField(write_only=True, required=True)
    nom_etablissement         = serializers.CharField(required=False, allow_blank=True, default='')
    adresse_etablissement     = serializers.CharField(required=False, allow_blank=True, default='')
    description_etablissement = serializers.CharField(required=False, allow_blank=True, default='')
    site_web                  = serializers.URLField(required=False, allow_blank=True, default='')

    class Meta:
        model  = Utilisateur
        fields = (
            'username', 'email', 'password', 'password_confirm',
            'role', 'telephone', 'first_name', 'last_name',
            'nom_etablissement', 'adresse_etablissement',
            'description_etablissement', 'site_web',
        )

    def validate(self, attrs):
        if attrs['password'] != attrs['password_confirm']:
            raise serializers.ValidationError({'password': 'Les mots de passe ne correspondent pas.'})
        if attrs.get('role') == 'PROFESSIONNEL' and not attrs.get('nom_etablissement', '').strip():
            raise serializers.ValidationError({'nom_etablissement': "Le nom de l'établissement est obligatoire pour un compte Pro."})
        return attrs

    def create(self, validated_data):
        validated_data.pop('password_confirm')
        nom_etablissement         = validated_data.pop('nom_etablissement', '').strip()
        adresse_etablissement     = validated_data.pop('adresse_etablissement', '').strip()
        description_etablissement = validated_data.pop('description_etablissement', '').strip()
        site_web                  = validated_data.pop('site_web', '').strip()
        user = Utilisateur.objects.create_user(**validated_data)
        if user.role == 'PROFESSIONNEL':
            profil = getattr(user, 'profil_professionnel', None)
            if profil:
                if nom_etablissement:
                    profil.nom_etablissement = nom_etablissement
                if adresse_etablissement:
                    profil.adresse = adresse_etablissement
                if description_etablissement:
                    profil.description_etablissement = description_etablissement
                if site_web:
                    profil.site_web = site_web
                profil.save()
        return user

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
        reservations = obj.reservations.exclude(statut__in=['ANNULEE', 'TERMINEE'])
        return ReservationSerializer(reservations, many=True).data
