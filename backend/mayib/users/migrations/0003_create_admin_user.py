from django.db import migrations


def create_admin(apps, schema_editor):
    from django.contrib.auth.hashers import make_password
    Utilisateur = apps.get_model('users', 'Utilisateur')

    accounts = [
        ('admin',  'admin@mayi.com',  'Admin',  'Mayi'),
        ('admin1', 'admin1@mayi.com', 'Admin1', 'Mayi'),
    ]

    for username, email, first_name, last_name in accounts:
        existing = Utilisateur.objects.filter(username=username).first()
        if existing:
            existing.role = 'ADMIN'
            existing.is_staff = True
            existing.is_superuser = True
            existing.is_active = True
            existing.save()
        else:
            Utilisateur.objects.create(
                username=username,
                email=email,
                password=make_password('mayi2025admin'),
                role='ADMIN',
                first_name=first_name,
                last_name=last_name,
                is_staff=True,
                is_superuser=True,
                is_active=True,
            )


def delete_admin(apps, schema_editor):
    Utilisateur = apps.get_model('users', 'Utilisateur')
    Utilisateur.objects.filter(username__in=['admin', 'admin1']).delete()


class Migration(migrations.Migration):

    dependencies = [
        ('users', '0002_email_unique_constraint'),
    ]

    operations = [
        migrations.RunPython(create_admin, delete_admin),
    ]
