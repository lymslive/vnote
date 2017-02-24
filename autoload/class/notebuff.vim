" Class: class#notebuff
" Author: lymslive
" Description: current buffer as note file
" Create: 2017-02-17
" Modify: 2017-02-17

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
let s:class = class#note#old()
let s:class._name_ = 'class#notebuff'
let s:class._version_ = 1

" buffer number of the note, 0 is current buffer
let s:buffer = 0

function! class#notebuff#class() abort "{{{
    return s:class
endfunction "}}}

" NEW:
function! class#notebuff#new(...) abort "{{{
    let l:obj = copy(s:class)
    call l:obj._new_(a:000)
    return l:obj
endfunction "}}}

" CTOR:
function! class#notebuff#ctor(this, argv) abort "{{{
    let l:Suctor = s:class._suctor_()
    let l:pFileName = expand('%:p')
    call l:Suctor(a:this, [l:pFileName])
endfunction "}}}

" ISOBJECT:
function! class#notebuff#isobject(that) abort "{{{
    return s:class._isobject_(a:that)
endfunction "}}}

" GetHeadLine:  overide base class
function! s:class.GetHeadLine(iMaxLine) dict abort "{{{
    return getline(1, a:iMaxLine)
endfunction "}}}

" UpdateTagFile: 
function! s:class.UpdateTagFile(jNoteBook) dict abort "{{{
    if !class#notebook#isobject(a:jNoteBook)
        echoerr 'expect a notebook objcet'
        return -1
    endif

    let l:lsTag = self.GetTagList()
    if empty(l:lsTag)
        return 0
    endif

    " note entry of current note
    let l:sNoteName = self.GetNoteName()
    let l:sTitle = self.GetNoteTitle()
    let l:sNoteEntry = l:sNoteName . "\t" . l:sTitle

    let l:pTagDir = a:jNoteBook.Tagdir()
    if !isdirectory(l:pTagDir)
        call mkdir(l:pTagDir, 'p')
    endif

    let l:iRet = 0
    for l:sTag in l:lsTag
        let l:sTag = tolower(l:sTag)

        " read in old notelist of that tag
        let l:pTagFile = l:pTagDir . '/' . l:sTag . '.tag'
        if filereadable(l:pTagFile)
            let l:lsNote = readfile(l:pTagFile)
        else
            let l:lsNote = []
        endif

        let l:bFound = v:false
        for l:note in l:lsNote
            if l:note =~ '^' . l:sNoteName
                let l:bFound = v:true
                break
            endif
        endfor

        if l:bFound == v:false
            call add(l:lsNote, l:sNoteEntry)

            " complex tag, treat as path
            if match(l:sTag, '/') != -1
                let l:idx = len(l:pTagFile) - 1
                while l:idx >= 0
                    if l:pTagFile[l:idx] == '/'
                        break
                    endif
                    let l:idx = l:idx - 1
                endwhile
                " trim the last /
                let l:pTagDir = strpart(l:pTagFile, 0, l:idx)
                if !isdirectory(l:pTagDir)
                    call mkdir(l:pTagDir, 'p')
                endif
            endif

            let l:iRet = writefile(l:lsNote, l:pTagFile)
            if l:iRet == 0
                :LOG 'update tag file: ' . l:sTag
            else
                break
            endif
        endif
    endfor

    return l:iRet
endfunction "}}}

" AddTag: 
function! s:class.AddTag(...) dict abort "{{{
    let l:list = medule#less#list#import()
    let l:lsTag = l:list.Flat(a:000)
    let l:iCount = 0
    for l:sTag in l:lsTag
        let l:iCount += self._AddTag(l:sTag)
    endfor
    return l:iCount
endfunction "}}}

" _AddTag: 
function! s:class._AddTag(sTag) dict abort "{{{
    " code
endfunction "}}}

" RemoveTag: 
function! s:class.RemoveTag(...) dict abort "{{{
    let l:list = medule#less#list#import()
    let l:lsTag = l:list.Flat(a:000)
    let l:iCount = 0
    for l:sTag in l:lsTag
        let l:iCount += self._RemoveTag(l:sTag)
    endfor
    return l:iCount
endfunction "}}}

" _RemoveTag: 
function! s:class._RemoveTag() dict abort "{{{
    " code
endfunction "}}}

" LOAD:
let s:load = 1
:DLOG 'class#notebuff is loading ...'
function! class#notebuff#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1) && exists('s:load')
        unlet s:load
        return 0
    endif
    return s:load
endfunction "}}}

" TEST:
function! class#notebuff#test(...) abort "{{{
    return 0
endfunction "}}}
