" Class: class#notescope#daterange
" Author: lymslive
" Description: note in a date range
" Create: 2017-03-16
" Modify: 2017-03-16

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
let s:class = class#notescope#old()
let s:class._name_ = 'class#notescope#daterange'
let s:class._version_ = 1

" date both ends, yyyy/mm/dd form, /mm/dd may ommit
let s:class.begday = ''
let s:class.endday = ''

function! class#notescope#daterange#class() abort "{{{
    return s:class
endfunction "}}}

" NEW:
function! class#notescope#daterange#new(...) abort "{{{
    let l:obj = copy(s:class)
    call l:obj._new_(a:000)
    return l:obj
endfunction "}}}

" CTOR:
function! class#notescope#daterange#ctor(this, argv) abort "{{{
    if len(a:argv) < 3
        :ELOG 'class#notescope#daterange expect (notebook, begday, endday)'
        return -1
    endif

    let l:Suctor = s:class._suctor_()
    call l:Suctor(a:this, [a:argv[0]])

    call a:this.SetBegday(a:argv[1])
    call a:this.SetEndday(a:argv[2])
endfunction "}}}

" ISOBJECT:
function! class#notescope#daterange#isobject(that) abort "{{{
    return s:class._isobject_(a:that)
endfunction "}}}

" SetBegday: 
function! s:class.SetBegday(day) dict abort "{{{
    if a:day !~# '^\d\{4\}'
        :ELOG 'expect date form yyyy[/mm/dd]'
        return -1
    endif

    let l:lsPart = split(a:day, '/')
    let l:iCount = len(l:lsPart)
    if l:iCount == 1
        let l:day = a:day . '/01/01'
    elseif l:iCount == 2
        let l:day = a:day . '/01'
    elseif l:iCount == 3
        let l:day = a:day
    else
        :ELOG 'expect date form yyyy[/mm/dd]'
        return -1
    endif

    let self.begday = l:day
endfunction "}}}

" SetEndday: 
function! s:class.SetEndday(day) dict abort "{{{
    if a:day !~# '^\d\{4\}'
        :ELOG 'expect date form yyyy[/mm/dd]'
        return -1
    endif

    let l:lsPart = split(a:day, '/')
    let l:iCount = len(l:lsPart)
    if l:iCount == 1
        let l:day = a:day . '/12/31'
    elseif l:iCount == 2
        let l:day = a:day . '/31'
    elseif l:iCount == 3
        let l:day = a:day
    else
        :ELOG 'expect date form yyyy[/mm/dd]'
        return -1
    endif

    let self.endday = l:day
endfunction "}}}

" list: 
function! s:class.list() dict abort "{{{
    let l:jFilter = class#notefilter#daterange#new
            \ (self.notebook, self.begday, self.endday)
    return l:jFilter.Filter()
endfunction "}}}

" LOAD:
let s:load = 1
:DLOG '-1 class#notescope#daterange is loading ...'
function! class#notescope#daterange#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1) && exists('s:load')
        unlet s:load
        return 0
    endif
    return s:load
endfunction "}}}

" TEST:
function! class#notescope#daterange#test(...) abort "{{{
    return 0
endfunction "}}}
