" Class: class#notebrowse#tag
" Author: lymslive
" Description: VimL class frame
" Create: 2017-03-16
" Modify: 2017-03-16

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
let s:class = class#notebrowse#old()
let s:class._name_ = 'class#notebrowse#tag'
let s:class._version_ = 1

let s:class.tagdir = ''
let s:class.taglead = ''

function! class#notebrowse#tag#class() abort "{{{
    return s:class
endfunction "}}}

" NEW: argv = [notebook, tagdir, taglead]
function! class#notebrowse#tag#new(...) abort "{{{
    let l:obj = copy(s:class)
    call l:obj._new_(a:000)
    return l:obj
endfunction "}}}
" CTOR:
function! class#notebrowse#tag#ctor(this, argv) abort "{{{
    if len(a:argv) < 3
        :ELOG 'class#notebrowse#tag#new(notebook, tagdir, taglead)'
        return -1
    endif

    let l:Suctor = s:class._suctor_()
    call l:Suctor(a:this, [a:argv[0]])

    let a:this.tagdir = a:argv[1]
    let a:this.taglead = a:argv[2]
endfunction "}}}

" ISOBJECT:
function! class#notebrowse#tag#isobject(that) abort "{{{
    return s:class._isobject_(a:that)
endfunction "}}}

" list: 
" only have *.tag files or subdirctory
function! s:class.list() dict abort "{{{
    let l:pDirectory = self.tagdir
    let l:ArgLead = self.taglead

    let l:iHead = len(l:pDirectory) + 1
    let l:lpTag = glob(l:pDirectory . '/' . l:ArgLead . '*', 0, 1)
    call map(l:lpTag, 'strpart(v:val, l:iHead)')

    let l:lsRet = []
    let l:lsPath = []
    let l:lsLeaf = []
    for l:sTag in l:lpTag
        if l:sTag =~ '\.tag$'
            let l:sTag = substitute(l:sTag, '\.tag$', '', '')
            if l:sTag == '+'
                call add(l:lsRet, l:sTag)
            elseif l:sTag == '-'
                call add(l:lsRet, l:sTag)
            else
                call add(l:lsLeaf, l:sTag)
            endif
        else
            let l:sTag = l:sTag . '/'
            call add(l:lsPath, l:sTag)
        endif
    endfor

    if !empty(l:lsPath)
        call sort(l:lsPath)
        call extend(l:lsRet, l:lsPath)
    endif
    if !empty(l:lsLeaf)
        call sort(l:lsLeaf)
        call extend(l:lsRet, l:lsLeaf)
    endif

    return l:lsRet
endfunction "}}}

" TransferScope: 
function! s:class.TransferScope() dict abort "{{{
    if !empty(self.taglead) && self.taglead !~# '/$'
        let l:rtp = module#less#rtp#import()
        let l:pTagFile = self.tagdir . l:rtp.separator . self.taglead . '.tag'
        if filereadable(l:pTagFile)
            return v:true
        endif
    endif
    return v:false
endfunction "}}}

" LOAD:
let s:load = 1
:DLOG '-1 class#notebrowse#tag is loading ...'
function! class#notebrowse#tag#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1) && exists('s:load')
        unlet s:load
        return 0
    endif
    return s:load
endfunction "}}}

" TEST:
function! class#notebrowse#tag#test(...) abort "{{{
    return 0
endfunction "}}}
