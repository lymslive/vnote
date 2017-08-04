" Class: class#notescope#date
" Author: lymslive
" Description: note of a specific date
" Create: 2017-03-16
" Modify: 2017-08-04

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
let s:class = class#notescope#old()
let s:class._name_ = 'class#notescope#date'
let s:class._version_ = 1

" date in path form
let s:class.date = ''

function! class#notescope#date#class() abort "{{{
    return s:class
endfunction "}}}

" NEW: argv = [notebook, date]
function! class#notescope#date#new(...) abort "{{{
    let l:obj = class#new(s:class, a:000)
    return l:obj
endfunction "}}}

" CTOR:
function! class#notescope#date#ctor(this, ...) abort "{{{
    if a:0 < 2
        :ELOG 'class#notescope#date expect (notebook, date)'
        return -1
    endif

    let l:Suctor = class#Suctor(s:class)
    call l:Suctor(a:this, a:1)

    if a:2 !~# '^\d\{4\}'
        :ELOG 'expect date form yyyy[/mm/dd]'
        return -1
    endif
    let a:this.date = a:2
endfunction "}}}

" ISOBJECT:
function! class#notescope#date#isobject(that) abort "{{{
    return class#isobject(s:class, a:that)
endfunction "}}}

" list: 
function! s:class.list() dict abort "{{{
    let l:lsNoteEntry = self.notebook.GlobNote(self.date)
    call map(l:lsNoteEntry, 'self.ConvertEntry(v:val)')
    return l:lsNoteEntry
endfunction "}}}

" LOAD:
let s:load = 1
:DLOG '-1 class#notescope#date is loading ...'
function! class#notescope#date#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1) && exists('s:load')
        unlet s:load
        return 0
    endif
    return s:load
endfunction "}}}

" TEST:
function! class#notescope#date#test(...) abort "{{{
    return 0
endfunction "}}}
