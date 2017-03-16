" Class: class#notescope
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
let s:class._name_ = 'class#notescope'
let s:class._version_ = 1
let s:class.notebook = {}
function! class#notescope#class() abort "{{{
    return s:class
endfunction "}}}

" NEW: argv = [notebook]
function! class#notescope#new(...) abort "{{{
    let l:obj = copy(s:class)
    call l:obj._new_(a:000)
    return l:obj
endfunction "}}}

" CTOR:
function! class#notescope#ctor(this, argv) abort "{{{
    if len(a:argv) < 1
        :ELOG 'class#notescope expect a notebook object'
        return -1
    elseif !class#notebook#isobject(a:argv[0])
        :ELOG 'class#notescope expect a notebook object'
        return -1
    else
        let a:this.notebook = a:argv[0]
        return 0
    endif
endfunction "}}}

" OLD:
function! class#notescope#old() abort "{{{
    let l:class = copy(s:class)
    call l:class._old_()
    return l:class
endfunction "}}}

" ISOBJECT:
function! class#notescope#isobject(that) abort "{{{
    return s:class._isobject_(a:that)
endfunction "}}}

" list: return a list of note entry in this scope
" sub-class should overide this method
" this base class only return all note in cache
function! s:class.list() dict abort "{{{
    let l:lsNoteEntry = self.notebook.ReadCache()
    if empty(l:lsNoteEntry)
        :DLOG 'cache empty, use glob to fetch all notes'
        let l:lsNoteEntry = self.notebook.GlobNote('')
        call map(l:lsNoteEntry, 'self.ConvertEntry(v:val)')
    endif
    return l:lsNoteEntry
endfunction "}}}

" ConvertEntry: return a note entry string from note file full path
function! s:class.ConvertEntry(pNoteFile) dict abort "{{{
    let l:jNote = class#note#new(a:pNoteFile)
    return l:jNote.GetNoteEntry()
endfunction "}}}

" LOAD:
let s:load = 1
:DLOG '-1 class#notescope is loading ...'
function! class#notescope#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1) && exists('s:load')
        unlet s:load
        return 0
    endif
    return s:load
endfunction "}}}

" TEST:
function! class#notescope#test(...) abort "{{{
    return 0
endfunction "}}}
