" Class: class#notecache#month
" Author: lymslive
" Description: VimL class frame
" Create: 2017-03-11
" Modify: 2017-08-04

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
    let l:obj = class#new(s:class, a:000)
    return l:obj
endfunction "}}}

" CTOR:
function! class#notecache#month#ctor(this, ...) abort "{{{
    let l:Suctor = class#Suctor(s:class)
    let l:path = get(a:000, 0, '')
    let l:cname = get(a:000, 1, s:class.cname)
    call l:Suctor(a:this, l:path, l:cname)
endfunction "}}}

" ISOBJECT:
function! class#notecache#month#isobject(that) abort "{{{
    return class#isobject(s:class, a:that)
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
