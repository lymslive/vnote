" Class: class#date
" Author: lymslive
" Description: a class deal with date
" Create: 2017-02-17
" Modify: 2017-02-17

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" BASIC:
let s:class = class#old()
let s:class._name_ = 'class#date'
let s:class._version_ = 1

let s:class.year = 0
let s:class.month = 0
let s:class.day = 0

function! class#date#class() abort "{{{
    return s:class
endfunction "}}}

" NEW:
function! class#date#new(...) abort "{{{
    let l:obj = copy(s:class)
    call l:obj._new_(a:000)
    return l:obj
endfunction "}}}

" CTOR:
function! class#date#ctor(this, argv) abort "{{{
    let l:argc = len(a:argv)

    if l:argc >= 3
        let a:this.year = a:argv[0]
        let a:this.month = a:argv[1]
        let a:this.day = a:argv[2]
        return 0
    endif

    if l:argc == 0
        let l:sDatePath = strftime("%Y/%m/%d") 
    elseif l:argc > 0
        let l:sDatePath = a:argv[0]
    endif

    if empty(l:sDatePath)
        return -1
    endif

    if match(l:sDatePath, '^\d\{8\}') != -1
        let a:this.year = strpart(l:sDatePath, 0, 4)
        let a:this.month = strpart(l:sDatePath, 4, 2)
        let a:this.day = strpart(l:sDatePath, 6, 2)
        return 0
    endif

    let l:lsSplit = split(l:sDatePath, '[^0-9]\+')
    if len(l:lsSplit) >= 3
        let a:this.year = l:lsSplit[0]
        let a:this.month = l:lsSplit[1]
        let a:this.day = l:lsSplit[2]
        return 0
    else
        return -1
    endif
endfunction "}}}

" ISOBJECT:
function! class#date#isobject(that) abort "{{{
    return s:class._isobject_(a:that)
endfunction "}}}

" CONVERSION: date as a string, join by sep
function! s:class.string(sep) dict abort "{{{
    return join([self.year, self.month, self.day], a:sep)
endfunction "}}}

" CONVERSION: date as a int, make up by 8 digit
function! s:class.number() dict abort "{{{
    return 0 + join([self.year, self.month, self.day], '')
endfunction "}}}

" ShiftDay: change day filed and return self objcet
function! s:class.ShiftDay(shift) dict abort "{{{
    let self.day += a:shift

    if self.day > 31
        let self.day = 1
    endif
    if self.day <= 0
        let self.day = 31 
    endif

    if self.day < 10
        let self.day = '0' . self.day
    endif

    return self
endfunction "}}}

" ShiftMonth: 
function! s:class.ShiftMonth(shift) dict abort "{{{
    let self.month += a:shift

    if self.month > 12
        let self.month = 1
    endif
    if self.month <= 0
        let self.month = 12 
    endif

    if self.month < 10
        let self.month = '0' . self.month
    endif

    return self
endfunction "}}}

" LOAD:
let s:load = 1
:DLOG 'class#date is loading ...'
function! class#date#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1) && exists('s:load')
        unlet s:load
        return 0
    endif
    return s:load
endfunction "}}}

" TEST:
function! class#date#test(...) abort "{{{
    let l:jDate = class#date#new()
    echo l:jDate.string('/')
    echo class#date#new().string('-')
    echo class#date#new().number()
    echo class#date#new('2010/10/10').number()
    echo class#date#new(20101010).string('.')
    echo class#date#new('20101010').string('=')
    return 0
endfunction "}}}
