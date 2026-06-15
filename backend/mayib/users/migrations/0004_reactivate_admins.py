from django.db import migrations


def reactivate_admins(apps, schema_editor):
    Utilisateur = apps.get_model('users', 'Utilisateur')
    Utilisateur.objects.filter(username__in=['admin', 'admin1']).update(
        is_active=True,
        role='ADMIN',
        is_staff=True,
        is_superuser=True,
    )


class Migration(migrations.Migration):

    dependencies = [
        ('users', '0003_create_admin_user'),
    ]

    operations = [
        migrations.RunPython(reactivate_admins, migrations.RunPython.noop),
    ]
