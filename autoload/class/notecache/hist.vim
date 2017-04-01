" Class: class#notecache#hist
" Author: lymslive
" Description: VimL class frame
" Create: 2017-03-11
" Modify: 2017-03-31

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
let s:class = class#notecache#old()
let s:class._name_ = 'class#notecache#hist'
let s:class._version_ = 1

" history cache is the uppest level cache
let s:class.cname = 'hist'
let s:class.uname = ''
let s:class.upper = ''
let s:class.leadkey = 0

function! class#notecache#hist#class() abort "{{{
    return s:class
endfunction "}}}

" NEW:
function! class#notecache#hist#new(...) abort "{{{
    let l:obj = copy(s:class)
    call l:obj._new_(a:000, 1)
    return l:obj
endfunction "}}}

" CTOR:
function! class#notecache#hist#ctor(this, ...) abort "{{{
    let l:Suctor = s:class._suctor_()
    let l:path = get(a:000, 0, '')
    let l:cname = get(a:000, 1, s:class.cname)
    call l:Suctor(a:this, l:path, l:cname)
endfunction "}}}

" ISOBJECT:
function! class#notecache#hist#isobject(that) abort "{{{
    return s:class._isobject_(a:that)
endfunction "}}}

" never need push up any more in the uppest level
function! s:class.NeedPush(sIncome, sCache) dict abort "{{{
    return g:class#FALSE
endfunction "}}}
function! s:class.PushCache() dict abort "{{{
    return 0
endfunction "}}}


" Rebuild: rebuild cache and optional tags (-t)
function! s:class.Rebuild(lpNote, lsOption) dict abort "{{{
    if empty(a:lpNote)
        return -1
    endif

    let l:lsCache = []
    let l:ldTag = {}
    let l:bTag = match(a:lsOption, '-t') >= 0

    for l:pNoteFile in a:lpNote
        let l:jNote = class#note#new(l:pNoteFile)
        let l:sNoteEntry = l:jNote.GetNoteEntry()

        call add(l:lsCache, l:sNoteEntry)

        if !l:bTag
            continue
        endif

        let l:lsTag = l:jNote.GetTagList()
        for l:sTag in l:lsTag
            if l:sTag ==# '-' || l:sTag ==# '+'
                continue
            endif
            let l:sTag = tolower(l:sTag)
            if !has_key(l:ldTag, l:sTag)
                let l:ldTag[l:sTag] = []
            endif
            call add(l:ldTag[l:sTag], l:sNoteEntry)
        endfor
    endfor

    let l:iErr = 0
    let l:iErr += self.ClearCache()
    let l:iErr += self.Write(l:lsCache)
    let l:iErr += self.SaveTag(l:ldTag)
    return l:iErr
endfunction "}}}

" ClearCache: clear minor caches
function! s:class.ClearCache() dict abort "{{{
    let l:lsName = ['day', 'month', 'year']
    let l:rtp = module#less#rtp#import()
    let l:iRet = 0
    for l:sName in l:lsName
        let l:pCacheName = self.path . l:rtp.separator . l:sName . self.EXTENTION
        if !filereadable(l:pCacheName)
            continue
        endif
        let l:iRet += delete(l:pCacheName)
    endfor

    :DLOG 'clear minor cache files: E' . l:iRet
    return l:iRet
endfunction "}}}

" SaveTag: 
" > a:ldTag, a dictionary, key is tag, value is a list of note entry having
"   that tag, creted by self.Rebuild()
function! s:class.SaveTag(ldTag) dict abort "{{{
    if empty(a:ldTag)
        return 0
    endif

    " hard code: convert <notebook>/c to <notebook>/t
    let l:pTagDir = substitute(self.path, 'c$', 't', '')
    if !isdirectory(l:pTagDir)
        call mkdir(l:pTagDir, 'p')
    endif

    let l:iRet = 0
    for l:sTag in keys(a:ldTag)
        let l:pTagFile = l:pTagDir . '/' . l:sTag . '.tag'
        if match(l:sTag, '/') != -1
            let l:pTagSubDir = fnamemodify(l:pTagFile, ':p:h')
            if !isdirectory(l:pTagSubDir)
                call mkdir(l:pTagSubDir, 'p')
            endif
        endif
        let l:iRet += writefile(a:ldTag[l:sTag], l:pTagFile)
    endfor

    :DLOG 'save tag fils: E' . l:iRet
    return l:iRet
endfunction "}}}

" LOAD:
let s:load = 1
:DLOG '-1 class#notecache#hist is loading ...'
function! class#notecache#hist#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1) && exists('s:load')
        unlet s:load
        return 0
    endif
    return s:load
endfunction "}}}

" TEST:
function! class#notecache#hist#test(...) abort "{{{
    return 0
endfunction "}}}
