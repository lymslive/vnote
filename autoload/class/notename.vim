" Class: class#notename
" Author: lymslive
" Description: a struct for parts of note filename
" Create: 2017-02-17
" Modify: 2017-02-17

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" note file name pattern
let s:PATTERN = '^\(\d\{8\}\)_\(\d\+\)\(-\?\)'

" CLASS:
let s:class = class#old()
let s:class._name_ = 'class#notename'
let s:class._version_ = 1

" file name part: yyyymmdd_n-.md
" noteid, yyyymmdd_n
" dateInt, yyyymmdd
" number, n
" private, -
let s:class.dateInt = 0
let s:class.noteNo = 0
let s:class.private = v:false

let s:class.year = 0
let s:class.month = 0
let s:class.day = 0

function! class#notename#class() abort "{{{
    return s:class
endfunction "}}}

" NEW:
function! class#notename#new(...) abort "{{{
    let l:obj = copy(s:class)
    call l:obj._new_(a:000)
    return l:obj
endfunction "}}}

" CTOR:
function! class#notename#ctor(this, argv) abort "{{{
    if len(a:argv) > 0 && !empty(a:argv[0])
        call a:this.ParseName(a:argv[0])
    else
        echoerr 'fails to construct class#notename'
    endif
endfunction "}}}

" ParseName: 
function! s:class.ParseName(filename) dict abort "{{{
    let l:sBaseName = fnamemodify(a:filename, ':t:r')
    let l:lsMatch = matchlist(l:sBaseName, s:PATTERN)
    if empty(l:lsMatch)
        echoerr 'not valid note file name: ' . l:sBaseName
    endif

    let self.dateInt = l:lsMatch[1]
    let self.dateNo = l:lsMatch[2]
    if empty(l:lsMatch[3])
        let self.private = v:false
    else
        let self.private = v:true
    endif

    call self.SplitDate_()
endfunction "}}}

" SplitDate_:
function! s:class.SplitDate_() dict abort "{{{
    let self.year = strpart(self.dateInt, 0, 4)
    let self.month = strpart(self.dateInt, 4, 2)
    let self.day = strpart(self.dateInt, 6, 2)
endfunction "}}}

" GetNoteID: 
function! s:class.GetNoteID() dict abort "{{{
    return self.dateInt . '_' . self.noteNo
endfunction "}}}

" IsPrivate: 
function! s:class.IsPrivate() dict abort "{{{
    return self.private
endfunction "}}}

" GetDatePath: 
function! s:class.GetDatePath() dict abort "{{{
    return join([self.year, self.month, self.day], '/')
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

    let self.dateInt = self.year . self.month . self.day
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

    let self.dateInt = self.year . self.month . self.day
    return self
endfunction "}}}

" ISOBJECT:
function! class#notename#isobject(that) abort "{{{
    return s:class._isobject_(a:that)
endfunction "}}}

" LOAD:
let s:load = 1
echo 'class#notename is loading ...'
function! class#notename#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1) && exists('s:load')
        unlet s:load
        return 0
    endif
    return s:load
endfunction "}}}

" TEST:
function! class#notename#test(...) abort "{{{
    return 0
endfunction "}}}
