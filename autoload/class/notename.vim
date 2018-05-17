" Class: class#notename
" Author: lymslive
" Description: a struct for parts of note filename
" Create: 2017-02-17
" Modify: 2017-08-04

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
let s:class.filename = ''
let s:class.dateInt = 0
let s:class.noteNo = 0
let s:class.private = v:false

function! class#notename#class() abort "{{{
    return s:class
endfunction "}}}

" NEW:
function! class#notename#new(...) abort "{{{
    let l:obj = class#new(s:class, a:000)
    return l:obj
endfunction "}}}

" CTOR:
function! class#notename#ctor(this, ...) abort "{{{
    if a:0 > 0 && !empty(a:1)
        call a:this.ParseName(a:1)
    else
        echoerr 'fails to construct class#notename'
    endif
endfunction "}}}

" ParseName: 
function! s:class.ParseName(filename) dict abort "{{{
    " let l:sBaseName = fnamemodify(a:filename, ':t:r')
    let l:lsMatch = matchlist(a:filename, s:PATTERN)
    if empty(l:lsMatch)
        " echoerr 'not valid note file name: ' . a:filename
        return -1
    endif

    let self.filename = l:lsMatch[0]
    let self.dateInt = l:lsMatch[1]
    let self.noteNo = l:lsMatch[2]
    if empty(l:lsMatch[3])
        let self.private = v:false
    else
        let self.private = v:true
    endif

endfunction "}}}

" GetNoteID: 
function! s:class.GetNoteID() dict abort "{{{
    return self.dateInt . '_' . self.noteNo
endfunction "}}}

" IsPrivate: 
function! s:class.IsPrivate() dict abort "{{{
    return self.private
endfunction "}}}

" GetDatePath: return yyyy/mm/dd
function! s:class.GetDatePath() dict abort "{{{
    if self.dateInt <= 0
        return ''
    endif

    let l:jDate = class#date#new(self.dateInt)
    return l:jDate.string('/')
endfunction "}}}

" GetFullPath: 
function! s:class.GetFullPath(jNoteBook) dict abort "{{{
    if empty(self.string())
        return ''
    endif

    let l:pNoteFile = self.GetDatePath() . '/' . self.string()
    if class#notebook#isobject(a:jNoteBook)
        let l:pDirectory = a:jNoteBook.Datedir()
        let l:sExtention = a:jNoteBook.suffix
        return l:pDirectory . '/' . l:pNoteFile . l:sExtention
    else
        return l:pNoteFile
    endif
endfunction "}}}

" string as filename
function! s:class.string() dict abort "{{{
    return self.filename
endfunction "}}}

" note number
function! s:class.number() dict abort "{{{
    return self.noteNo
endfunction "}}}

" IsValid: 
function! s:class.IsValid() dict abort "{{{
    return !empty(self.filename)
endfunction "}}}

" ISOBJECT:
function! class#notename#isobject(that) abort "{{{
    return class#isobject(s:class, a:that)
endfunction "}}}

" LOAD:
let s:load = 1
:DLOG 'class#notename is loading ...'
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
