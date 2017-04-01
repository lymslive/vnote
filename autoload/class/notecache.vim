" Class: class#notecache
" Author: lymslive
" Description: VimL class frame
" Create: 2017-03-11
" Modify: 2017-03-31

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
let s:class = class#old()
let s:class._name_ = 'class#notecache'
let s:class._version_ = 1

" the dirctory path where cache locate
let s:class.path = ''

" current level cache name
let s:class.cname = ''
" next upper level cache name
let s:class.uname = ''
" the full class name of next level
let s:class.upper = ''

" extention of cache file
let s:class.EXTENTION = '.che'

" the length of leading key to compare
let s:class.leadkey = 0

function! class#notecache#class() abort "{{{
    return s:class
endfunction "}}}

" NEW:
function! class#notecache#new(...) abort "{{{
    :ELOG 'virtual class#notecache should not create object'
    return -1
endfunction "}}}

" CTOR:
function! class#notecache#ctor(this, ...) abort "{{{
    if a:0 < 1
        :ELOG 'class#notecache expect a dirctory path'
        return -1
    else
        let a:this.path = a:1
    endif

    if a:0 >= 2
        let a:this.cname = a:2
    endif
endfunction "}}}

" PullEntry: pull a list of entry to self cache
function! s:class.PullEntry(lsEntry) dict abort "{{{
    if empty(a:lsEntry) || type(a:lsEntry) != type([])
        :ELOG 'class#notecache.Pull expect a list'
        return -1
    endif

    let l:sIncome = a:lsEntry[0]
    let l:sCache = self.Sample()
    if empty(l:sCache)
        return self.Write(a:lsEntry)
    endif

    if self.NeedPush(l:sIncome, l:sCache)
        let l:iRet = self.PushCache()
        if l:iRet != 0
            :ELOG 'push fails: ' . self._name_
            return l:iRet
        else
            return self.Write(a:lsEntry)
        endif
    else
        return self.Write(a:lsEntry, 'a')
    endif
endfunction "}}}

" PushCache: push up this cache to the next cache
function! s:class.PushCache() dict abort "{{{
    let l:jUpper = class#new(self.upper, self.path, self.uname)
    let l:lsCache = self.Read()
    return l:jUpper.PullEntry(l:lsCache)
endfunction "}}}

" NeedPush: check need push up or directory append
" > a:1, a:sIncome, the new entry sample
" > a:2, a:sCache, the origin entry sample
"   are string, the first entry is ok
function! s:class.NeedPush(sIncome, sCache) dict abort "{{{
    if empty(a:sCache)
        return g:class#FALSE
    endif

    if len(a:sCache) < 8 || len(a:sIncome) < 8
        :ELOG 'seems invalid cache entry?'
        return g:class#FALSE
    endif

    let l:sIncome = strpart(a:sIncome, 0, self.leadkey)
    let l:sCache = strpart(a:sCache, 0, self.leadkey)

    if l:sIncome ==# l:sCache
        return g:class#FALSE
    else
        return g:class#TRUE
    endif
endfunction "}}}

" CacheFile: 
function! s:class.CacheFile() dict abort "{{{
    let l:rtp = module#less#rtp#import()
    return self.path . l:rtp.separator . self.cname . self.EXTENTION
endfunction "}}}

" ReadOK: 
function! s:class.ReadOK() dict abort "{{{
    let l:pFileName = self.CacheFile()
    return filereadable(l:pFileName)
endfunction "}}}

" Read: return the list of entry of current cache
function! s:class.Read() dict abort "{{{
    if self.ReadOK()
        return readfile(self.CacheFile())
    else
        return []
    endif
endfunction "}}}

" Sample: return the first line
function! s:class.Sample() dict abort "{{{
    let l:sample = get(self, 'sample_', '')
    if !empty(l:sample)
        return l:sample
    endif

    if self.ReadOK()
        let l:sample = readfile(self.CacheFile(), 0, 1)[0]
        let self.sample_ = l:sample
    endif

    return l:sample
endfunction "}}}

" WirteOK: 
function! s:class.WirteOK() dict abort "{{{
    let l:pFileName = self.CacheFile()
    return filewritable(l:pFileName)
endfunction "}}}

" Write: 
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

    let l:pFileName = self.CacheFile()
    let l:iErr = writefile(a:lsEntry, l:pFileName, l:flag)
    :DLOG 'save cache file: ' . self.cname . ' E' . l:iErr
    return l:iErr
endfunction "}}}

" ISOBJECT:
function! class#notecache#isobject(that) abort "{{{
    return s:class._isobject_(a:that)
endfunction "}}}

" OLD:
function! class#notecache#old() abort "{{{
    let l:class = copy(s:class)
    call l:class._old_()
    return l:class
endfunction "}}}

" LOAD:
let s:load = 1
:DLOG '-1 class#notecache is loading ...'
function! class#notecache#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1) && exists('s:load')
        unlet s:load
        return 0
    endif
    return s:load
endfunction "}}}

" TEST:
function! class#notecache#test(...) abort "{{{
    return 0
endfunction "}}}
