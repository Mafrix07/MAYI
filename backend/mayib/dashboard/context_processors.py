from reviews.models import Avis
from support.models import Ticket

def dashboard_context(request):
    """
    Fournit des variables de contexte globales pour le dashboard Mayi.
    """
    if request.user.is_authenticated and (request.user.is_staff or request.user.role in ['ADMIN', 'SUPPORT']):
        pending_reviews_count = Avis.objects.filter(est_signale=True).count()
        open_tickets_count = Ticket.objects.filter(statut='OUVERT').count()
        return {
            'pending_reviews_count': pending_reviews_count,
            'open_tickets_count': open_tickets_count,
            'notifications_count': pending_reviews_count + open_tickets_count,
        }
    return {
        'pending_reviews_count': 0,
        'open_tickets_count': 0,
        'notifications_count': 0,
    }
