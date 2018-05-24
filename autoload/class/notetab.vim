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

" InitView: load 3 init buffer in 3 window
" must called after layout to split 3 window
function! s:class.InitView() dict abort "{{{
    " notebar
    :1wincmd w
    let l:pBarName = self.notebook.GetBarName()
    if expand('%:p') !=# l:pBarName
        execute 'edit ' . l:pBarName
    endif
    let b:jNoteBar = self.notebook.CreateBar()
    call b:jNoteBar.RefreshBar()

    let l:pTagdb = self.notebook.GetTagdbFile()
    if !filereadable(l:pTagdb)
        " default blank notebar document
        let l:pBlank = vnote#GetBlankBar()
        let l:lsBlank = readfile(l:pBlank)
        setlocal modifiable
        call append('$', l:lsBlank)
        setlocal nomodifiable
    endif

    " notelist
    :2wincmd w
    let l:pListerName = self.notebook.GetListerName()
    if expand('%:p') !=# l:pListerName
        execute 'edit ' . l:pListerName
    endif
    let b:jNoteList = self.notebook.CreateLister()
    call b:jNoteList.RefreshList(['-m'])

    let l:bMruEmpty = self.notebook.MruEmpty()
    if l:bMruEmpty
        let l:pBlank = vnote#GetBlankList()
        let l:lsBlank = readfile(l:pBlank)
        setlocal modifiable
        call append('$', l:lsBlank)
        setlocal nomodifiable
    endif

    " markdown note
    :3wincmd w
    if !l:bMruEmpty
        call notebook#hNoteEdit(-1)
    else
        let l:pBlank = vnote#GetBlankNote()
        execute 'edit ' . l:pBlank
    endif
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
