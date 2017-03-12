" Class: class#notecache#hist
" Author: lymslive
" Description: VimL class frame
" Create: 2017-03-11
" Modify: 2017-03-13

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
let s:class = class#notecache#old()
let s:class._name_ = 'class#notecache#hist'
let s:class._version_ = 1

" history cache is the uppest level cache
let s:class.cname = 'hist'
let s:class.uname = ''
let s:class.upper = ''
let s:class.leadkey = 0

function! class#notecache#hist#class() abort "{{{
    return s:class
endfunction "}}}

" NEW:
function! class#notecache#hist#new(...) abort "{{{
    let l:obj = copy(s:class)
    call l:obj._new_(a:000)
    return l:obj
endfunction "}}}

" CTOR:
function! class#notecache#hist#ctor(this, argv) abort "{{{
    let l:Suctor = s:class._suctor_()
    call l:Suctor(a:this, a:argv)
endfunction "}}}

" ISOBJECT:
function! class#notecache#hist#isobject(that) abort "{{{
    return s:class._isobject_(a:that)
endfunction "}}}

" never need push up any more in the uppest level
function! s:class.NeedPush(sIncome, sCache) dict abort "{{{
    return v:false
endfunction "}}}
function! s:class.PushCache() dict abort "{{{
    return 0
endfunction "}}}


" LOAD:
let s:load = 1
:DLOG '-1 class#notecache#hist is loading ...'
function! class#notecache#hist#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1) && exists('s:load')
        unlet s:load
        return 0
    endif
    return s:load
endfunction "}}}

" TEST:
function! class#notecache#hist#test(...) abort "{{{
    return 0
endfunction "}}}
