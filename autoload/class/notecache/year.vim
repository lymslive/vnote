" Class: class#notecache#year
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
let s:class._name_ = 'class#notecache#year'
let s:class._version_ = 1

let s:class.cname = 'year'
let s:class.uname = 'hist'
let s:class.upper = 'class#notecache#hist'
let s:class.leadkey = 4

function! class#notecache#year#class() abort "{{{
    return s:class
endfunction "}}}

" NEW:
function! class#notecache#year#new(...) abort "{{{
    let l:obj = class#new(s:class, a:000)
    return l:obj
endfunction "}}}

" CTOR:
function! class#notecache#year#ctor(this, ...) abort "{{{
    let l:Suctor = class#Suctor(s:class)
    let l:path = get(a:000, 0, '')
    let l:cname = get(a:000, 1, s:class.cname)
    call l:Suctor(a:this, l:path, l:cname)
endfunction "}}}

" ISOBJECT:
function! class#notecache#year#isobject(that) abort "{{{
    return class#isobject(s:class, a:that)
endfunction "}}}

" LOAD:
let s:load = 1
:DLOG '-1 class#notecache#year is loading ...'
function! class#notecache#year#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1) && exists('s:load')
        unlet s:load
        return 0
    endif
    return s:load
endfunction "}}}

" TEST:
function! class#notecache#year#test(...) abort "{{{
    return 0
endfunction "}}}
