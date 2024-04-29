from django.urls import path

from . import views

urlpatterns = [
    path('', views.index, name='index'),
    path('api/notes/', views.api_notes),
    path('api/notes/<int:note_id>/', views.api_note),
    path('index', views.index, name='index'),
    path('tag/index', views.index, name='index'),
    path('tags', views.tags, name='tags'),
    path('tag/<int:tag_id>', views.tag, name='tag'),
    path('delete/<int:note_id>', views.delete, name='delete'),
    path('update/<int:note_id>', views.update, name='update'),
    path('delete_tag/<int:tag_id>', views.delete_tag, name='delete_tag'),
    path('delete_tag_card/<int:tag_id>/<int:note_id>', views.delete_tag_card, name='delete_tag_card'),
    path('update_tag/<int:tag_id>/<int:note_id>', views.update_tag, name='update_tag')
]