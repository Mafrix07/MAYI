from rest_framework import serializers
from .models import Ticket, MessageTicket

class MessageTicketSerializer(serializers.ModelSerializer):
    auteur_nom = serializers.ReadOnlyField(source='auteur.username')

    class Meta:
        model = MessageTicket
        fields = ['id', 'ticket', 'auteur', 'auteur_nom', 'contenu', 'date_envoi']
        read_only_fields = ['auteur']

class TicketSerializer(serializers.ModelSerializer):
    utilisateur_nom = serializers.ReadOnlyField(source='utilisateur.username')
    assigne_a_nom = serializers.ReadOnlyField(source='assigne_a.username')
    messages = MessageTicketSerializer(many=True, read_only=True)

    class Meta:
        model = Ticket
        fields = (
            'id', 'sujet', 'description', 'type_ticket', 'statut', 
            'date_creation', 'utilisateur', 'utilisateur_nom', 
            'assigne_a', 'assigne_a_nom', 'reservation', 'messages'
        )
        read_only_fields = ['utilisateur', 'statut', 'assigne_a']
