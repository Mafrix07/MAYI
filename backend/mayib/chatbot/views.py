import os
import io
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework.parsers import MultiPartParser, FormParser, JSONParser
from PIL import Image
import google.generativeai as genai

_SYSTEM_PROMPT = """Tu es MayiBot, l'assistant touristique officiel de l'application Mayi Togo Tourism.
Tu es spécialisé dans le tourisme au Togo. Quand l'utilisateur te montre la photo d'un monument,
site naturel, plage, marché ou lieu touristique, tu dois répondre en français avec ces sections :

📍 Identification du lieu
Le nom du site et un bref contexte historique ou culturel.

🗺️ Localisation
La ville, la région et la position approximative (au Togo si possible).

🧭 Itinéraire depuis Lomé
Comment s'y rendre depuis Lomé : transport disponible, durée et distance.

🏨 Hébergements à proximité
Les hôtels, auberges ou logements proches du site.

🍽️ Restaurants et snacks
Les endroits où manger autour du site (restaurants, maquis, snacks).

💡 Conseils pratiques
Meilleure période pour visiter, tarif d'entrée si applicable, conseils de sécurité.

Si la photo ne correspond pas à un lieu touristique, réponds poliment et propose d'analyser
une autre photo. Si l'utilisateur pose une question sans photo, réponds en te basant sur
ta connaissance du tourisme au Togo."""


class ChatbotAnalyzeView(APIView):
    permission_classes = [IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser, JSONParser]

    def post(self, request):
        api_key = os.getenv('GEMINI_API_KEY')
        if not api_key:
            return Response(
                {'error': 'Le service IA n\'est pas encore configuré. Contactez l\'administrateur.'},
                status=503,
            )

        question = (request.data.get('question') or '').strip()
        image_file = request.FILES.get('image')

        if not image_file and not question:
            return Response(
                {'error': 'Envoyez une photo ou posez une question.'},
                status=400,
            )

        genai.configure(api_key=api_key)
        model = genai.GenerativeModel('gemini-1.5-flash')

        try:
            if image_file:
                image_bytes = image_file.read()
                image = Image.open(io.BytesIO(image_bytes))
                user_question = question or 'Analyse ce site touristique et donne-moi toutes les informations utiles.'
                prompt = f"{_SYSTEM_PROMPT}\n\nQuestion de l'utilisateur : {user_question}"
                response = model.generate_content([image, prompt])
            else:
                prompt = f"{_SYSTEM_PROMPT}\n\nQuestion : {question}"
                response = model.generate_content(prompt)

            return Response({'response': response.text})

        except Exception as exc:
            return Response(
                {'error': f'Erreur lors de l\'analyse : {str(exc)}'},
                status=500,
            )
