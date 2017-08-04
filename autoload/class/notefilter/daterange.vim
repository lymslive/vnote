" Class: class#notefilter#daterange
" Author: lymslive
" Description: VimL class frame
" Create: 2017-03-16
" Modify: 2017-08-04

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
let s:class = class#notefilter#old()
let s:class._name_ = 'class#notefilter#daterange'
let s:class._version_ = 1

" date both ends, yyyymmdd form, as an int number
let s:class.begday = 0
let s:class.endday = 0

function! class#notefilter#daterange#class() abort "{{{
    return s:class
endfunction "}}}

" NEW:
function! class#notefilter#daterange#new(...) abort "{{{
    let l:obj = class#new(s:class, a:000)
    return l:obj
endfunction "}}}

" CTOR:
function! class#notefilter#daterange#ctor(this, ...) abort "{{{
    if a:0 < 3
        :ELOG 'class#notefilter#daterange expect (notebook, begday, endday)'
        return -1
    endif

    let l:Suctor = class#Suctor(s:class)
    call l:Suctor(a:this, a:1)

    let a:this.begday = 0 + substitute(a:2, '[^0-9]\+', '', 'g')
    let a:this.endday = 0 + substitute(a:3, '[^0-9]\+', '', 'g')

    if a:this.begday > a:this.endday
        :WLOG 'the date range seems incorrect, try to swap'
        let l:iTemp = a:this.begday
        let a:this.begday = a:this.endday
        let a:this.endday = l:iTemp
    endif
endfunction "}}}

" ISOBJECT:
function! class#notefilter#daterange#isobject(that) abort "{{{
    return class#isobject(s:class, a:that)
endfunction "}}}

" NoteObjectOK: 
function! s:class.NoteObjectOK(jNote) dict abort "{{{
    return self.NoteEntryOK(a:jNote.GetNoteName(), a:jNote.GetNoteTitle())
endfunction "}}}
" NoteEntryOK: 
function! s:class.NoteEntryOK(sNoteName, sNoteTitle) dict abort "{{{
    let l:iDateInt = 0 + a:sNoteName
    return l:iDateInt >= self.begday && l:iDateInt <= self.endday
endfunction "}}}

" LOAD:
let s:load = 1
:DLOG '-1 class#notefilter#daterange is loading ...'
function! class#notefilter#daterange#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1) && exists('s:load')
        unlet s:load
        return 0
    endif
    return s:load
endfunction "}}}

" TEST:
function! class#notefilter#daterange#test(...) abort "{{{
    return 0
endfunction "}}}
