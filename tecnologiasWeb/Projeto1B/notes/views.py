from django.shortcuts import render, redirect
from rest_framework.decorators import api_view
from rest_framework.response import Response
from django.http import Http404
from .models import Tag, Note
from .serializers import NoteSerializer

def index(request):
    if request.method == 'POST':
        title = request.POST.get('titulo')
        content = request.POST.get('detalhes')
        tag = request.POST.get('tag')
        # TAREFA: Utilize o title e content para criar um novo Note no banco de dados]
        t_filter = Tag.objects.filter(name=tag)
        if len(t_filter) > 0:
            t = Tag.objects.get(name=tag)
        else:
            t = Tag(name=tag)
            t.save()
        
        n = Note(title=title, content=content, tag = t)
        n.save()
        
        return redirect('index')
    else:
        all_notes = Note.objects.all()
        all_tags = Tag.objects.all()
        return render(request, 'notes/index.html', {'notes': all_notes, 'tags': all_tags})
    
def delete(request, note_id):
    # TAREFA: Utilize o note_id para deletar o Note correto do banco de dados
    n = Note.objects.get(id=note_id)
    n.delete()
    return redirect('index')

def delete_tag(request, tag_id):
    # TAREFA: Utilize o tag_id para deletar a Tag correta do banco de dados
    t = Tag.objects.get(id=tag_id)
    t.delete()

    notes = Note.objects.filter(tag=t)
    for note in notes:
        note.delete()

    all_tags = Tag.objects.all()

    if len(all_tags) == 0:
        return redirect('index')
    else:       
        return redirect('tags')

def delete_tag_card(request, tag_id, note_id):
    # TAREFA: Utilize o tag_id para deletar a Tag correta do banco de dados
    t = Tag.objects.get(id=tag_id)
    notes = Note.objects.filter(tag=t)

    note = Note.objects.get(id=note_id)
    note.delete()
    
    if len(notes) == 0:
        t.delete()
        return redirect('tags')
    else:
        return redirect('tag', tag_id)

def update(request, note_id):
    if request.method == 'POST':
        title = request.POST.get('titulo')
        content = request.POST.get('detalhes')
        tag = request.POST.get('tag')
        # TAREFA: Utilize o title e content para atualizar o Note correto no banco de dados
        t_filter = Tag.objects.filter(name=tag)
        if len(t_filter) > 0:
            t = Tag.objects.get(name=tag)
        else:
            t = Tag(name=tag)
            t.save()
        n = Note.objects.get(id=note_id)
        n.title = title
        n.content = content
        n.tag = t
        n.save()
        return redirect('index')
    else:
        note = Note.objects.get(id=note_id)
        return render(request, 'notes/update.html', {'note': note})
    
def tags(request):
    if request.method == 'GET':
        all_tags = Tag.objects.all()
        return render(request, 'notes/tags.html', {'tags': all_tags})
    
def tag(request, tag_id):
    if request.method == 'GET':
        tag = Tag.objects.get(id=tag_id)
        return render(request, 'notes/tag.html', {'tag': tag})
    
def update_tag(request, tag_id, note_id):
    if request.method == 'POST':
        title = request.POST.get('titulo')
        content = request.POST.get('detalhes')
        tag = request.POST.get('tag')
        # TAREFA: Utilize o title e content para atualizar o Note correto no banco de dados
        t_filter = Tag.objects.filter(name=tag)
        if len(t_filter) > 0:
            t = Tag.objects.get(name=tag)
        else:
            t = Tag(name=tag)
            t.save()
        notes = Note.objects.filter(tag=t)
        n = Note.objects.get(id=note_id)
        n.title = title
        n.content = content
        n.tag = t
        n.save()
        if len(notes) == 0:
            return redirect('tags')
        else:
            return redirect('tag', tag_id)
    else:
        note = Note.objects.get(id=note_id)
        return render(request, 'notes/update.html', {'note': note})
    
@api_view(['GET', 'POST'])
def api_note(request, note_id):
    try:
        note = Note.objects.get(id=note_id)
    except Note.DoesNotExist:
        raise Http404()
    if request.method == 'POST':
        new_note_data = request.data
        note.title = new_note_data['title']
        note.content = new_note_data['content']
        note.save()

    serialized_note = NoteSerializer(note)
    return Response(serialized_note.data)

@api_view(['GET', 'POST'])
def api_notes(request):
    if request.method == 'POST':
        new_note_data = request.data
        new_note = Note.objects.create(
            title=new_note_data['title'],
            content=new_note_data['content']
        )
        serialized_note = NoteSerializer(new_note)
        return Response(serialized_note.data)
    else:
        all_notes = Note.objects.all()
        serialized_notes = NoteSerializer(all_notes, many=True)
        return Response(serialized_notes.data)