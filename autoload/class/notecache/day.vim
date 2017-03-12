" Class: class#notecache#day
" Author: lymslive
" Description: VimL class frame
" Create: 2017-03-11
" Modify: 2017-03-12

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
let s:class = class#notecache#old()
let s:class._name_ = 'class#notecache#day'
let s:class._version_ = 1

let s:class.cname = 'day'
let s:class.uname = 'month'
let s:class.upper = 'class#notecache#month'
let s:class.leadkey = 8

function! class#notecache#day#class() abort "{{{
    return s:class
endfunction "}}}

" NEW:
function! class#notecache#day#new(...) abort "{{{
    let l:obj = copy(s:class)
    call l:obj._new_(a:000)
    return l:obj
endfunction "}}}

" CTOR:
function! class#notecache#day#ctor(this, argv) abort "{{{
    let l:Suctor = s:class._suctor_()
    call l:Suctor(a:this, a:argv)
endfunction "}}}

" ISOBJECT:
function! class#notecache#day#isobject(that) abort "{{{
    return s:class._isobject_(a:that)
endfunction "}}}

" LOAD:
let s:load = 1
:DLOG '-1 class#notecache#day is loading ...'
function! class#notecache#day#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1) && exists('s:load')
        unlet s:load
        return 0
    endif
    return s:load
endfunction "}}}

" TEST:
function! class#notecache#day#test(...) abort "{{{
    return 0
endfunction "}}}
