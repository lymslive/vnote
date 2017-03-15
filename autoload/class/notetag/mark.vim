" Class: class#notetag#mark
" Author: lymslive
" Description: manually bookmark tag in /m subdirctory
" Create: 2017-03-15
" Modify: 2017-03-15

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
let s:class = class#notetag#old()
let s:class._name_ = 'class#notetag#mark'
let s:class._version_ = 1

function! class#notetag#mark#class() abort "{{{
    return s:class
endfunction "}}}

" NEW:
function! class#notetag#mark#new(...) abort "{{{
    let l:obj = copy(s:class)
    call l:obj._new_(a:000)
    return l:obj
endfunction "}}}

" CTOR:
function! class#notetag#mark#ctor(this, argv) abort "{{{
    let l:Suctor = s:class._suctor_()
    call l:Suctor(a:this, a:argv)
endfunction "}}}

" ISOBJECT:
function! class#notetag#mark#isobject(that) abort "{{{
    return s:class._isobject_(a:that)
endfunction "}}}

" GetTagFile: 
function! s:class.GetTagFile() dict abort "{{{
    let l:rtp = module#less#rtp#import()
    return self.notebook.Markdir() . l:rtp.separator . self.tag . '.tag'
endfunction "}}}

" LOAD:
let s:load = 1
:DLOG '-1 class#notetag#mark is loading ...'
function! class#notetag#mark#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1) && exists('s:load')
        unlet s:load
        return 0
    endif
    return s:load
endfunction "}}}

" TEST:
function! class#notetag#mark#test(...) abort "{{{
    return 0
endfunction "}}}
