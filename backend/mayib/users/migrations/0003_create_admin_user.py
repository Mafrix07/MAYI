from django.db import migrations


def create_admin(apps, schema_editor):
    Utilisateur = apps.get_model('users', 'Utilisateur')
    if not Utilisateur.objects.filter(username='admin').exists():
        from django.contrib.auth.hashers import make_password
        Utilisateur.objects.create(
            username='admin',
            email='admin@mayi.com',
            password=make_password('mayi2025admin'),
            role='ADMIN',
            first_name='Admin',
            last_name='Mayi',
            is_staff=True,
            is_superuser=True,
            is_active=True,
        )


def delete_admin(apps, schema_editor):
    Utilisateur = apps.get_model('users', 'Utilisateur')
    Utilisateur.objects.filter(username='admin', email='admin@mayi.com').delete()


class Migration(migrations.Migration):

    dependencies = [
        ('users', '0002_email_unique_constraint'),
    ]

    operations = [
        migrations.RunPython(create_admin, delete_admin),
    ]
