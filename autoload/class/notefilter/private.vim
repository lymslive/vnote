" Class: class#notefilter#private
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
let s:class._name_ = 'class#notefilter#private'
let s:class._version_ = 1

function! class#notefilter#private#class() abort "{{{
    return s:class
endfunction "}}}

" NEW:
function! class#notefilter#private#new(...) abort "{{{
    let l:obj = copy(s:class)
    call l:obj._new_(a:000)
    return l:obj
endfunction "}}}

" CTOR:
function! class#notefilter#private#ctor(this, argv) abort "{{{
    let l:Suctor = s:class._suctor_()
    call l:Suctor(a:this, a:argv)
endfunction "}}}

" ISOBJECT:
function! class#notefilter#private#isobject(that) abort "{{{
    return s:class._isobject_(a:that)
endfunction "}}}

" NoteObjectOK: 
function! s:class.NoteObjectOK(jNote) dict abort "{{{
    return self.NoteEntryOK(a:jNote.GetNoteName(), a:jNote.GetNoteTitle())
endfunction "}}}
" NoteEntryOK: 
function! s:class.NoteEntryOK(sNoteName, sNoteTitle) dict abort "{{{
    let l:jNoteEntry = class#notename#new(a:sNoteName)
    return !empty(l:jNoteEntry.string()) && l:jNoteEntry.IsPrivate()
endfunction "}}}

" LOAD:
let s:load = 1
:DLOG '-1 class#notefilter#private is loading ...'
function! class#notefilter#private#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1) && exists('s:load')
        unlet s:load
        return 0
    endif
    return s:load
endfunction "}}}

" TEST:
function! class#notefilter#private#test(...) abort "{{{
    return 0
endfunction "}}}
