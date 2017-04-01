" Class: class#notefilter
" Author: lymslive
" Description: VimL class frame
" Create: 2017-03-16
" Modify: 2017-03-16

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
let s:class = class#old()
let s:class._name_ = 'class#notefilter'
let s:class._version_ = 1

let s:class.notebook = {}

function! class#notefilter#class() abort "{{{
    return s:class
endfunction "}}}

" NEW:
function! class#notefilter#new(...) abort "{{{
    let l:obj = copy(s:class)
    call l:obj._new_(a:000)
    return l:obj
endfunction "}}}

" CTOR:
function! class#notefilter#ctor(this, argv) abort "{{{
    if len(a:argv) < 1
        :ELOG 'class#notefilter expect a notebook object'
        return -1
    elseif !class#notebook#isobject(a:argv[0])
        :ELOG 'class#notefilter expect a notebook object'
        return -1
    else
        let a:this.notebook = a:argv[0]
        return 0
    endif
endfunction "}}}

" ISOBJECT:
function! class#notefilter#isobject(that) abort "{{{
    return s:class._isobject_(a:that)
endfunction "}}}

" OLD:
function! class#notefilter#old() abort "{{{
    let l:class = copy(s:class)
    call l:class._old_()
    return l:class
endfunction "}}}

" ok: 
function! s:class.ok(val) dict abort "{{{
    if empty(a:val)
        return g:class#FALSE
    elseif class#note#isobject(a:val)
        return self.NoteObjectOK(a:val)
    else
        let l:lsPart = split(a:val, "\t")
        if len(l:lsPart) < 2
            :ELOG 'It seems not valid note entry: ' . a:val
            return g:class#FALSE
        endif
        let l:sNoteName = l:lsPart[0]
        let l:sNoteTitle = l:lsPart[1]
        return self.NoteEntryOK(l:sNoteName, l:sNoteTitle)
    endif
endfunction "}}}

" NoteObjectOK: 
function! s:class.NoteObjectOK(jNote) dict abort "{{{
    return g:class#TRUE
endfunction "}}}
" NoteEntryOK: 
function! s:class.NoteEntryOK(sNoteName, sNoteTitle) dict abort "{{{
    return g:class#TRUE
endfunction "}}}

" Filter: filter a:lsInput in-place, default all note entry
function! s:class.Filter(...) dict abort "{{{
    if a:0 == 0
        let l:lsInput = class#notescope#new(self.notebook).list()
    else
        let l:lsInput = a:1
    endif

    if empty(l:lsInput) || type(l:lsInput) != type([])
        return []
    endif
    return filter(l:lsInput, 'self.ok(v:val)')
endfunction "}}}

" LOAD:
let s:load = 1
:DLOG '-1 class#notefilter is loading ...'
function! class#notefilter#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1) && exists('s:load')
        unlet s:load
        return 0
    endif
    return s:load
endfunction "}}}

" TEST:
function! class#notefilter#test(...) abort "{{{
    return 0
endfunction "}}}
