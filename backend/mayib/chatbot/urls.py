from django.urls import path
from .views import ChatbotAnalyzeView

urlpatterns = [
    path('chatbot/analyze/', ChatbotAnalyzeView.as_view(), name='chatbot-analyze'),
]
