" Class: class#notescope#tag
" Author: lymslive
" Description: note with a specific tag, directly read tag file
" Create: 2017-03-16
" Modify: 2017-03-16

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
let s:class = class#notescope#old()
let s:class._name_ = 'class#notescope#tag'
let s:class._version_ = 1

let s:class.tagdir = ''
let s:class.tagname = ''

function! class#notescope#tag#class() abort "{{{
    return s:class
endfunction "}}}

" NEW:
function! class#notescope#tag#new(...) abort "{{{
    let l:obj = copy(s:class)
    call l:obj._new_(a:000)
    return l:obj
endfunction "}}}

" CTOR:
function! class#notescope#tag#ctor(this, argv) abort "{{{
    if len(a:argv) < 3
        :ELOG 'class#notescope#tag expect (notebook, tagdir, tagname)'
        return -1
    endif

    let l:Suctor = s:class._suctor_()
    call l:Suctor(a:this, [a:argv[0]])

    let a:this.tagdir = a:argv[1]
    let a:this.tagname = a:argv[2]
endfunction "}}}

" ISOBJECT:
function! class#notescope#tag#isobject(that) abort "{{{
    return s:class._isobject_(a:that)
endfunction "}}}

" GetTagFile: 
function! s:class.GetTagFile() dict abort "{{{
    let l:rtp = module#less#rtp#import()
    return self.tagdir . l:rtp.separator . self.tagname . '.tag'
endfunction "}}}

" list: the list of content lines
function! s:class.list() dict abort "{{{
    if self.tagname ==# 'mru' && self.tagdir =~# '/m$'
        return self.notebook.GetMruList()
    endif

    let l:pTagFile = self.GetTagFile()
    if filereadable(l:pTagFile)
        return readfile(l:pTagFile)
    else
        if l:sTag ==# '-'
            return self.notebook.GetPrivateNote()
        elseif l:sTag ==# '+'
            return self.notebook.GetPublicNote()
        else
            echo 'the notebook has no tag: ' . l:sTag
            return []
        endif
    endif
endfunction "}}}

" LOAD:
let s:load = 1
:DLOG '-1 class#notescope#tag is loading ...'
function! class#notescope#tag#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1) && exists('s:load')
        unlet s:load
        return 0
    endif
    return s:load
endfunction "}}}

" TEST:
function! class#notescope#tag#test(...) abort "{{{
    return 0
endfunction "}}}
