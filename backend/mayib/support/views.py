from django.shortcuts import render

# Create your views here.
from rest_framework import viewsets, permissions, status
from .models import *
from .serializers import *


class TicketViewSet(viewsets.ModelViewSet):
    serializer_class = TicketSerializer

    def get_queryset(self):
        return Ticket.objects.filter(utilisateur=self.request.user)
    def perform_create(self, serializer):
        serializer.save(utilisateur=self.request.user)



class MessageTicketViewSet(viewsets.ModelViewSet):
    serializer_class = MessageTicketSerializer
    def get_queryset(self):
        return MessageTicket.objects.filter(ticket__utilisateur=self.request.user)

    def perform_create(self, serializer):
        serializer.save(auteur=self.request.user)
