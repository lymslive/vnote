" Class: class#notebuff
" Author: lymslive
" Description: current buffer as note file
" Create: 2017-02-17
" Modify: 2017-02-17

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
let s:class = class#note#old()
let s:class._name_ = 'class#notebuff'
let s:class._version_ = 1

" buffer number of the note, 0 is current buffer
let s:buffer = 0

function! class#notebuff#class() abort "{{{
    return s:class
endfunction "}}}

" NEW:
function! class#notebuff#new(...) abort "{{{
    let l:obj = copy(s:class)
    call l:obj._new_(a:000)
    return l:obj
endfunction "}}}

" CTOR:
function! class#notebuff#ctor(this, argv) abort "{{{
    let l:Suctor = s:class._suctor_()
    let l:pFileName = expand('%:p')
    call l:Suctor(a:this, [l:pFileName])
endfunction "}}}

" ISOBJECT:
function! class#notebuff#isobject(that) abort "{{{
    return s:class._isobject_(a:that)
endfunction "}}}

" GetHeadLine:  overide base class
function! s:class.GetHeadLine(iMaxLine) dict abort "{{{
    return getline(1, a:iMaxLine)
endfunction "}}}

" LOAD:
let s:load = 1
:DLOG 'class#notebuff is loading ...'
function! class#notebuff#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1) && exists('s:load')
        unlet s:load
        return 0
    endif
    return s:load
endfunction "}}}

" TEST:
function! class#notebuff#test(...) abort "{{{
    return 0
endfunction "}}}
