# Generated by Django 4.1.7 on 2023-03-16 13:07

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('notes', '0002_tag_note_tag'),
    ]

    operations = [
        migrations.AddField(
            model_name='tag',
            name='name',
            field=models.CharField(default='', max_length=200),
            preserve_default=False,
        ),
    ]