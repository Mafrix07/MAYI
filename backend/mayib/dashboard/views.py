import csv
from django.http import HttpResponse
from django.shortcuts import render, get_object_or_404, redirect
from django.contrib.auth.decorators import login_required
from .permissions import staff_required
from users.models import Utilisateur
from reservations.models import Reservation
from services.models import Service
from reviews.models import Avis
from support.models import Ticket, MessageTicket
from django.utils import timezone
from datetime import timedelta
from django.db.models import Count, Q
from django.db.models.functions import TruncDate
from django.core.paginator import Paginator
from django.contrib import messages
from django.contrib.auth.views import LoginView
from django.contrib.auth import login
from rest_framework_simplejwt.tokens import AccessToken
from django.contrib.auth import get_user_model

def auto_login(request):
    """Connexion automatique depuis Flutter via JWT"""
    token = request.GET.get('token')
    if not token:
        return redirect('dashboard:login')
    try:
        # Vérifier et décoder le token JWT
        access_token = AccessToken(token)
        user_id = access_token['user_id']
        User = get_user_model()
        user = User.objects.get(id=user_id)
        # Vérifier que c'est bien un STAFF ou ADMIN
        if user.role not in ['STAFF', 'ADMIN']:
            return redirect('dashboard:login')
        # Créer la session Django
        login(request, user,
            backend='django.contrib.auth.backends.ModelBackend')
        return redirect('dashboard:index')
    except Exception:
        return redirect('dashboard:login')
class MayiLoginView(LoginView):
    template_name = 'dashboard/mayi_login.html'

@staff_required
def index(request):
    # KPIs
    total_users = Utilisateur.objects.count()
    total_services = Service.objects.filter(est_actif=True).count()
    pending_reviews = Avis.objects.filter(est_signale=True).count()
    
    # Reservations this month
    now = timezone.now()
    month_start = now.replace(day=1, hour=0, minute=0, second=0, microsecond=0)
    reservations_this_month = Reservation.objects.filter(date_creation__gte=month_start).count()

    # Data for Chart.js: Reservations last 30 days
    last_30_days = now - timedelta(days=30)
    res_stats = Reservation.objects.filter(date_creation__gte=last_30_days) \
        .annotate(date=TruncDate('date_creation')) \
        .values('date') \
        .annotate(count=Count('id')) \
        .order_by('date')
    
    chart_res_labels = [stat['date'].strftime('%d %b') for stat in res_stats]
    chart_res_data = [stat['count'] for stat in res_stats]

    # Data for Chart.js: Service distribution
    service_stats = Service.objects.values('type_service').annotate(count=Count('id'))
    chart_service_labels = [stat['type_service'] for stat in service_stats]
    chart_service_data = [stat['count'] for stat in service_stats]

    # Recent Activity
    recent_reservations = Reservation.objects.select_related('touriste', 'service').order_by('-date_creation')[:5]
    recent_users = Utilisateur.objects.order_by('-date_creation')[:5]

    context = {
        'total_users': total_users,
        'total_services': total_services,
        'pending_reviews': pending_reviews,
        'reservations_this_month': reservations_this_month,
        'chart_res_labels': chart_res_labels,
        'chart_res_data': chart_res_data,
        'chart_service_labels': chart_service_labels,
        'chart_service_data': chart_service_data,
        'recent_reservations': recent_reservations,
        'recent_users': recent_users,
    }
    return render(request, 'dashboard/index.html', context)

@staff_required
def user_list(request):
    users = Utilisateur.objects.all().order_by('-date_joined')
    
    # Search
    search = request.GET.get('search')
    if search:
        users = users.filter(
            Q(username__icontains=search) | 
            Q(email__icontains=search) | 
            Q(first_name__icontains=search) | 
            Q(last_name__icontains=search)
        )
    
    # Filter by Role
    role_filter = request.GET.get('role')
    if role_filter:
        users = users.filter(role=role_filter)
    
    # Pagination
    paginator = Paginator(users, 10)
    page_number = request.GET.get('page')
    page_obj = paginator.get_page(page_number)
    
    context = {
        'page_obj': page_obj,
        'search': search,
        'role_filter': role_filter,
        'roles': Utilisateur.Role.choices,
    }
    return render(request, 'dashboard/users/list.html', context)

@staff_required
def user_detail(request, pk):
    user_obj = get_object_or_404(Utilisateur, pk=pk)
    
    # User activity
    reservations = Reservation.objects.filter(touriste=user_obj).order_by('-date_creation')[:10]
    avis = Avis.objects.filter(touriste=user_obj).order_by('-date_creation')[:10]
    
    context = {
        'user_obj': user_obj,
        'reservations': reservations,
        'avis': avis,
    }
    return render(request, 'dashboard/users/detail.html', context)

@staff_required
def user_toggle_status(request, pk):
    user_obj = get_object_or_404(Utilisateur, pk=pk)
    if user_obj == request.user:
        messages.error(request, "Vous ne pouvez pas vous désactiver vous-même.")
    else:
        user_obj.is_active = not user_obj.is_active
        user_obj.save()
        status = "activé" if user_obj.is_active else "désactivé"
        messages.success(request, f"L'utilisateur {user_obj.username} a été {status}.")
    
    return redirect(request.META.get('HTTP_REFERER', 'dashboard:user_list'))

@staff_required
def service_list(request):
    services = Service.objects.all().select_related('professionnel').order_by('-date_creation')
    
    # Search
    search = request.GET.get('search')
    if search:
        services = services.filter(
            Q(nom__icontains=search) | 
            Q(description__icontains=search)
        )
    
    # Filter by Type
    type_filter = request.GET.get('type')
    if type_filter:
        services = services.filter(type_service=type_filter)
    
    # Filter by Status
    status_filter = request.GET.get('status')
    if status_filter == 'active':
        services = services.filter(est_actif=True)
    elif status_filter == 'inactive':
        services = services.filter(est_actif=False)
    elif status_filter == 'reported':
        services = services.filter(est_signale=True)
    
    # Pagination
    paginator = Paginator(services, 10)
    page_number = request.GET.get('page')
    page_obj = paginator.get_page(page_number)
    
    context = {
        'page_obj': page_obj,
        'search': search,
        'type_filter': type_filter,
        'status_filter': status_filter,
        'types': Service.TypeService.choices,
    }
    return render(request, 'dashboard/services/list.html', context)

@staff_required
def service_detail(request, pk):
    service_obj = get_object_or_404(Service.objects.select_related('professionnel__utilisateur'), pk=pk)
    photos = service_obj.photos.all()
    reservations = service_obj.reservations.all().order_by('-date_creation')[:10]
    
    context = {
        'service_obj': service_obj,
        'photos': photos,
        'reservations': reservations,
    }
    return render(request, 'dashboard/services/detail.html', context)

@staff_required
def service_toggle_status(request, pk):
    service_obj = get_object_or_404(Service, pk=pk)
    service_obj.est_actif = not service_obj.est_actif
    service_obj.save()
    status = "activé" if service_obj.est_actif else "désactivé"
    messages.success(request, f"Le service {service_obj.nom} a été {status}.")
    return redirect(request.META.get('HTTP_REFERER', 'dashboard:service_list'))

@staff_required
def reservation_list(request):
    reservations = Reservation.objects.all().select_related('touriste', 'service').order_by('-date_creation')
    
    # Filters
    status_filter = request.GET.get('status')
    if status_filter:
        reservations = reservations.filter(statut=status_filter)
        
    date_start = request.GET.get('date_start')
    if date_start:
        reservations = reservations.filter(date_debut__gte=date_start)
        
    # Pagination
    paginator = Paginator(reservations, 15)
    page_number = request.GET.get('page')
    page_obj = paginator.get_page(page_number)
    
    context = {
        'page_obj': page_obj,
        'status_filter': status_filter,
        'date_start': date_start,
        'statuses': Reservation.Statut.choices,
    }
    return render(request, 'dashboard/reservations/list.html', context)

@staff_required
def reservation_detail(request, pk):
    res_obj = get_object_or_404(Reservation.objects.select_related('touriste', 'service', 'service__professionnel__utilisateur'), pk=pk)
    try:
        paiement_acompte = res_obj.paiement_acompte
    except:
        paiement_acompte = None
        
    try:
        paiement_solde = res_obj.paiement_solde
    except:
        paiement_solde = None
        
    context = {
        'res_obj': res_obj,
        'paiement_acompte': paiement_acompte,
        'paiement_solde': paiement_solde,
        'statuses': Reservation.Statut.choices,
    }
    return render(request, 'dashboard/reservations/detail.html', context)

@staff_required
def reservation_change_status(request, pk):
    if request.method == 'POST':
        res_obj = get_object_or_404(Reservation, pk=pk)
        new_status = request.POST.get('status')
        if new_status in dict(Reservation.Statut.choices):
            res_obj.statut = new_status
            res_obj.save()
            messages.success(request, f"Le statut de la réservation #{pk} a été mis à jour.")
    return redirect(request.META.get('HTTP_REFERER', 'dashboard:reservation_list'))

@staff_required
def reservation_export_csv(request):
    response = HttpResponse(content_type='text/csv')
    response['Content-Disposition'] = 'attachment; filename="reservations.csv"'
    
    writer = csv.writer(response)
    writer.writerow(['ID', 'Client', 'Service', 'Date Début', 'Prix Total', 'Statut', 'Date Création'])
    
    reservations = Reservation.objects.all().select_related('touriste', 'service')
    for res in reservations:
        writer.writerow([
            res.pk, 
            res.touriste.username, 
            res.service.nom, 
            res.date_debut, 
            res.prix_total, 
            res.get_statut_display(), 
            res.date_creation
        ])
    
    return response

@staff_required
def review_list(request):
    reviews = Avis.objects.all().select_related('touriste', 'service').order_by('-date_creation')
    
    # Filter by Reported
    reported_only = request.GET.get('reported')
    if reported_only == '1':
        reviews = reviews.filter(est_signale=True)
        
    # Pagination
    paginator = Paginator(reviews, 15)
    page_number = request.GET.get('page')
    page_obj = paginator.get_page(page_number)
    
    context = {
        'page_obj': page_obj,
        'reported_only': reported_only,
    }
    return render(request, 'dashboard/reviews/list.html', context)

@staff_required
def review_approve(request, pk):
    review = get_object_or_404(Avis, pk=pk)
    review.est_signale = False
    review.save()
    messages.success(request, "L'avis a été approuvé et le signalement a été retiré.")
    return redirect(request.META.get('HTTP_REFERER', 'dashboard:review_list'))

@staff_required
def review_delete(request, pk):
    review = get_object_or_404(Avis, pk=pk)
    review.delete()
    messages.success(request, "L'avis a été supprimé définitivement.")
    return redirect(request.META.get('HTTP_REFERER', 'dashboard:review_list'))

@staff_required
def support_list(request):
    tickets = Ticket.objects.all().select_related('utilisateur', 'assigne_a').order_by('-date_creation')
    
    # Filters
    status_filter = request.GET.get('status')
    if status_filter:
        tickets = tickets.filter(statut=status_filter)
        
    type_filter = request.GET.get('type')
    if type_filter:
        tickets = tickets.filter(type_ticket=type_filter)
        
    # Pagination
    paginator = Paginator(tickets, 15)
    page_number = request.GET.get('page')
    page_obj = paginator.get_page(page_number)
    
    context = {
        'page_obj': page_obj,
        'status_filter': status_filter,
        'type_filter': type_filter,
        'statuses': Ticket.Statut.choices,
        'types': Ticket.TypeTicket.choices,
    }
    return render(request, 'dashboard/support/list.html', context)

@staff_required
def support_detail(request, pk):
    ticket = get_object_or_404(Ticket.objects.select_related('utilisateur', 'assigne_a', 'reservation'), pk=pk)
    messages_list = ticket.messages.all().select_related('auteur')
    
    if request.method == 'POST':
        contenu = request.POST.get('message')
        if contenu:
            MessageTicket.objects.create(
                ticket=ticket,
                auteur=request.user,
                contenu=contenu
            )
            # Auto update status to EN_COURS if it was OUVERT
            if ticket.statut == Ticket.Statut.OUVERT:
                ticket.statut = Ticket.Statut.EN_COURS
                ticket.save()
            messages.success(request, "Votre réponse a été envoyée.")
            return redirect('dashboard:support_detail', pk=pk)
            
    context = {
        'ticket': ticket,
        'messages_list': messages_list,
        'statuses': Ticket.Statut.choices,
    }
    return render(request, 'dashboard/support/detail.html', context)

@staff_required
def support_change_status(request, pk):
    if request.method == 'POST':
        ticket = get_object_or_404(Ticket, pk=pk)
        new_status = request.POST.get('status')
        if new_status in dict(Ticket.Statut.choices):
            ticket.statut = new_status
            if new_status in [Ticket.Statut.RESOLU, Ticket.Statut.FERME]:
                ticket.date_resolution = timezone.now()
            ticket.save()
            messages.success(request, f"Le statut du ticket #{pk} a été mis à jour.")
    return redirect(request.META.get('HTTP_REFERER', 'dashboard:support_list'))
