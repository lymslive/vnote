" Class: class#notefilter#public
" Author: lymslive
" Description: VimL class frame
" Create: 2017-03-16
" Modify: 2017-03-16

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
let s:class = class#notefilter#old()
let s:class._name_ = 'class#notefilter#public'
let s:class._version_ = 1

function! class#notefilter#public#class() abort "{{{
    return s:class
endfunction "}}}

" NEW:
function! class#notefilter#public#new(...) abort "{{{
    let l:obj = copy(s:class)
    call l:obj._new_(a:000)
    return l:obj
endfunction "}}}

" CTOR:
function! class#notefilter#public#ctor(this, argv) abort "{{{
    let l:Suctor = s:class._suctor_()
    call l:Suctor(a:this, a:argv)
endfunction "}}}

" ISOBJECT:
function! class#notefilter#public#isobject(that) abort "{{{
    return s:class._isobject_(a:that)
endfunction "}}}

" NoteObjectOK: 
function! s:class.NoteObjectOK(jNote) dict abort "{{{
    return self.NoteEntryOK(a:jNote.GetNoteName(), a:jNote.GetNoteTitle())
endfunction "}}}
" NoteEntryOK: 
function! s:class.NoteEntryOK(sNoteName, sNoteTitle) dict abort "{{{
    let l:jNoteEntry = class#notename#new(a:sNoteName)
    return !empty(l:jNoteEntry.string()) && !l:jNoteEntry.IsPrivate()
endfunction "}}}

" LOAD:
let s:load = 1
:DLOG '-1 class#notefilter#public is loading ...'
function! class#notefilter#public#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1) && exists('s:load')
        unlet s:load
        return 0
    endif
    return s:load
endfunction "}}}

" TEST:
function! class#notefilter#public#test(...) abort "{{{
    return 0
endfunction "}}}
