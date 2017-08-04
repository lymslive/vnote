" Class: class#notebrowse
" Author: lymslive
" Description: browse the directory that contains note
" Create: 2017-03-16
" Modify: 2017-08-04

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
let s:class = class#old()
let s:class._name_ = 'class#notebrowse'
let s:class._version_ = 1
let s:class.notebook = {}

function! class#notebrowse#class() abort "{{{
    return s:class
endfunction "}}}

" NEW: argv = [notebook]
function! class#notebrowse#new(...) abort "{{{
    let l:obj = class#new(s:class, a:000)
    return l:obj
endfunction "}}}
" CTOR:
function! class#notebrowse#ctor(this, ...) abort "{{{
    if a:0 < 1
        :ELOG 'class#notebrowse expect a notebook object'
        return -1
    elseif !class#notebook#isobject(a:1)
        :ELOG 'class#notebrowse expect a notebook object'
        return -1
    else
        let a:this.notebook = a:1
        return 0
    endif
endfunction "}}}

" OLD:
function! class#notebrowse#old() abort "{{{
    let l:class = class#old(s:class)
    return l:class
endfunction "}}}

" ISOBJECT:
function! class#notebrowse#isobject(that) abort "{{{
    return class#isobject(s:class, a:that)
endfunction "}}}

" list: 
function! s:class.list() dict abort "{{{
    return []
endfunction "}}}

" TransferScope: 
function! s:class.TransferScope() dict abort "{{{
    return g:class#FALSE
endfunction "}}}

" LOAD:
let s:load = 1
:DLOG '-1 class#notebrowse is loading ...'
function! class#notebrowse#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1) && exists('s:load')
        unlet s:load
        return 0
    endif
    return s:load
endfunction "}}}

" TEST:
function! class#notebrowse#test(...) abort "{{{
    return 0
endfunction "}}}
