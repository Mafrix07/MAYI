from decimal import Decimal
from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.exceptions import PermissionDenied
from rest_framework.response import Response
from rest_framework.parsers import MultiPartParser, FormParser
from .models import Reservation, PaiementAcompte
from .serializers import ReservationSerializer
from users.permissions import IsTouriste, IsSupportOrAdmin

class ReservationViewSet(viewsets.ModelViewSet):
    serializer_class = ReservationSerializer
    http_method_names = ['get', 'post', 'patch', 'head', 'options']

    def get_queryset(self):
        user = self.request.user
        if not user.is_authenticated:
            return Reservation.objects.none()
        if user.role == 'TOURISTE':
            return Reservation.objects.filter(touriste=user).select_related('service', 'touriste')
        elif user.role == 'PROFESSIONNEL':
            return Reservation.objects.filter(service__professionnel__utilisateur=user).select_related('service', 'touriste')
        return Reservation.objects.all().select_related('service', 'touriste')

    def get_permissions(self):
        if self.action in ['list', 'retrieve', 'confirmer_paiement']:
            return [permissions.IsAuthenticated()]
        elif self.action == 'create':
            return [permissions.IsAuthenticated(), IsTouriste()]
        elif self.action == 'partial_update':
            return [permissions.IsAuthenticated()]
        return [permissions.IsAuthenticated(), IsSupportOrAdmin()]

    def perform_create(self, serializer):
        service = serializer.validated_data['service']
        serializer.save(
            touriste=self.request.user,
            prix_total=service.prix,
            type_reservation='HEBERGEMENT',
            type_acompte='POURCENTAGE',
            valeur_acompte=Decimal('10.0')
        )

    @action(detail=True, methods=['post'])
    def annuler(self, request, pk=None):
        reservation = self.get_object()
        if reservation.touriste != request.user:
            raise PermissionDenied('Seul le touriste peut annuler sa réservation.')
        if reservation.statut in ['TERMINEE', 'ANNULEE']:
            return Response({'error': 'Cette réservation ne peut plus être annulée.'}, status=status.HTTP_400_BAD_REQUEST)
        reservation.statut = 'ANNULEE'
        reservation.save()
        return Response({'message': 'Réservation annulée.'}, status=status.HTTP_200_OK)

    @action(detail=True, methods=['post'], parser_classes=[MultiPartParser, FormParser])
    def confirmer_paiement(self, request, pk=None):
        reservation = self.get_object()
        if 'capture_ecran' not in request.FILES:
            return Response({'error': 'Aucune capture d''écran fournie.'}, status=status.HTTP_400_BAD_REQUEST)
        
        paiement, created = PaiementAcompte.objects.get_or_create(
            reservation=reservation,
            defaults={
                'operateur': 'TMONEY',
                'mode_verification': 'MANUELLE',
                'numero_telephone': '00000000',
                'reference_transaction': 'TEMP_REF',
                'montant': reservation.montant_acompte
            }
        )
        paiement.capture_ecran = request.FILES['capture_ecran']
        paiement.save()
        
        reservation.statut = 'ACOMPTE_EN_VERIFICATION'
        reservation.save()
        
        return Response({'message': 'Paiement envoyé pour vérification.'}, status=status.HTTP_200_OK)

    def partial_update(self, request, *args, **kwargs):
        instance = self.get_object()
        allowed_fields = {'statut'}
        provided_fields = set(request.data.keys())
        if not provided_fields.issubset(allowed_fields):
            raise PermissionDenied('Seul le champ statut peut être modifié.')
        is_touriste_owner = (instance.touriste == request.user)
        is_pro_owner = (instance.service.professionnel.utilisateur == request.user)
        is_staff = request.user.role in ['ADMIN', 'SUPPORT']
        if not (is_touriste_owner or is_pro_owner or is_staff):
            raise PermissionDenied('Permission refusée.')
        return super().partial_update(request, *args, **kwargs)
