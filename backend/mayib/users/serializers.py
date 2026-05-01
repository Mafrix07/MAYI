from rest_framework import serializers
from .models import Utilisateur
from django.contrib.auth.password_validation import validate_password


class InscriptionSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, required=True, validators=)