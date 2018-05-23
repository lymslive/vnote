" Class: class#notetab
" Author: lymslive
" Description: VimL class frame
" Create: 2018-05-21
" Modify: 2018-05-21

" LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
let s:class = class#viml#tabapp#old()
let s:class._name_ = 'class#notetab'
let s:class._version_ = 1
let s:class.notebook = {}

function! class#notetab#class() abort "{{{
    return s:class
endfunction "}}}

" NEW:
function! class#notetab#new(...) abort "{{{
    let l:obj = class#new(s:class, a:000)
    return l:obj
endfunction "}}}
" CTOR:
function! class#notetab#ctor(this, ...) abort "{{{
    let a:this.tabname = 'vnote'
    let a:this.winnum = 3
    let a:this.laycmd = '+20||'
    let a:this.needft = 'notebar|notelist|markdown'
    if a:0 > 0 && class#notebook#isobject(a:1)
        let a:this.notebook = a:1
    else
        :ELOG 'class#notetab need a notebook object'
    endif
endfunction "}}}

" ISOBJECT:
function! class#notetab#isobject(that) abort "{{{
    return class#isobject(s:class, a:that)
endfunction "}}}

" InitView: 
function! s:class.InitView() dict abort "{{{
    " notebar
    :1wincmd w
    let b:jNoteBar = self.notebook.CreateBar()
    call b:jNoteBar.RefreshBar()

    " notelist
    :2wincmd w
    let b:jNoteList = self.notebook.CreateLister()
    call b:jNoteList.RefreshList(['-m'])

    " markdown note
    :3wincmd w
    call notebook#hNoteEdit(-1)
endfunction "}}}

" LOAD:
let s:load = 1
function! class#notetab#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1)
        unlet! s:load
    endif
endfunction "}}}

" TEST:
function! class#notetab#test(...) abort "{{{
    let l:obj = class#notetab#new()
    call class#echo(l:obj)
endfunction "}}}
