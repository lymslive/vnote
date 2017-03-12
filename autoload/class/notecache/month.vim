" Class: class#notecache#month
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
let s:class._name_ = 'class#notecache#month'
let s:class._version_ = 1

let s:class.cname = 'month'
let s:class.uname = 'year'
let s:class.upper = 'class#notecache#year'
let s:class.leadkey = 6

function! class#notecache#month#class() abort "{{{
    return s:class
endfunction "}}}

" NEW:
function! class#notecache#month#new(...) abort "{{{
    let l:obj = copy(s:class)
    call l:obj._new_(a:000)
    return l:obj
endfunction "}}}

" CTOR:
function! class#notecache#month#ctor(this, argv) abort "{{{
    let l:Suctor = s:class._suctor_()
    call l:Suctor(a:this, a:argv)
endfunction "}}}

" ISOBJECT:
function! class#notecache#month#isobject(that) abort "{{{
    return s:class._isobject_(a:that)
endfunction "}}}

" LOAD:
let s:load = 1
:DLOG '-1 class#notecache#month is loading ...'
function! class#notecache#month#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1) && exists('s:load')
        unlet s:load
        return 0
    endif
    return s:load
endfunction "}}}

" TEST:
function! class#notecache#month#test(...) abort "{{{
    return 0
endfunction "}}}
