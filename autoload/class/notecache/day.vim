" Class: class#notecache#day
" Author: lymslive
" Description: VimL class frame
" Create: 2017-03-11
" Modify: 2017-03-14

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
let s:class = class#notecache#old()
let s:class._name_ = 'class#notecache#day'
let s:class._version_ = 1

let s:class.cname = 'day'
let s:class.uname = 'month'
let s:class.upper = 'class#notecache#month'
let s:class.leadkey = 8

function! class#notecache#day#class() abort "{{{
    return s:class
endfunction "}}}

" NEW:
function! class#notecache#day#new(...) abort "{{{
    let l:obj = copy(s:class)
    call l:obj._new_(a:000)
    return l:obj
endfunction "}}}

" CTOR:
function! class#notecache#day#ctor(this, argv) abort "{{{
    let l:Suctor = s:class._suctor_()
    call l:Suctor(a:this, a:argv)
endfunction "}}}

" ISOBJECT:
function! class#notecache#day#isobject(that) abort "{{{
    return s:class._isobject_(a:that)
endfunction "}}}

" Write: day.che need check repeated entry
" > a:1, flag to writefile(), 'a' is append
function! s:class.Write(lsEntry, ...) dict abort "{{{
    if a:0 == 0
        let l:flag = ''
    else
        let l:flag = a:1
    endif

    if !isdirectory(self.path)
        call mkdir(self.path, 'p')
    endif

    if !has_key(self, 'cache_')
        let self.cache_ = self.Read()
    endif

    let l:pFileName = self.CacheFile()
    if l:flag =~? 'a'
        let l:lsCache = self.cache_
        for l:sEntry in a:lsEntry
            let l:sNoteName = split(l:sEntry, "\t")[0]
            let l:iFound = match(l:lsCache, '^' . l:sNoteName)
            if l:iFound == -1
                call add(l:lsCache, l:sEntry)
            else
                let l:lsCache[l:iFound] = l:sEntry
            endif
        endfor
        let l:iErr = writefile(l:lsCache, l:pFileName)
    else
        let l:lsCache = a:lsEntry
        let self.cache_ = l:lsCache
    endif

    let l:iErr = writefile(l:lsCache, l:pFileName)
    :DLOG 'save cache file: ' . self.cname . ' E' . l:iErr
    return l:iErr
endfunction "}}}

" ReadAll: merge all cache file and return as list
function! s:class.ReadAll() dict abort "{{{
    let l:rtp = module#less#rtp#import()
    let l:lsAll = []

    let l:lsName = ['hist', 'year', 'month', 'day']
    for l:sName in l:lsName
        let l:pCacheName = self.path . l:rtp.separator . l:sName . self.EXTENTION
        if filereadable(l:pCacheName)
            call extend(l:lsAll, readfile(l:pCacheName))
        endif
    endfor

    return l:lsAll
endfunction "}}}

" LOAD:
let s:load = 1
:DLOG '-1 class#notecache#day is loading ...'
function! class#notecache#day#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1) && exists('s:load')
        unlet s:load
        return 0
    endif
    return s:load
endfunction "}}}

" TEST:
function! class#notecache#day#test(...) abort "{{{
    return 0
endfunction "}}}
