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
" let s:class.bufnr = 0

" saved tag cache
let s:class.tagsave = {}

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
    if len(a:argv) > 0
        call l:Suctor(a:this, [l:pFileName, a:argv[0]])
    else
        call l:Suctor(a:this, [l:pFileName])
    endif
    let a:this.tagsave = {}
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
function! s:class.UpdateTagFile() dict abort "{{{
    let l:lsTag = self.GetTagList()
    if empty(l:lsTag)
        return 0
    endif

    for l:sTag in l:lsTag
        let l:iRet = self.UpdateOneTag(l:sTag)
        if l:iRet != 0
            return l:iRet
        endif
    endfor

    return 0
endfunction "}}}

" UpdateOneTag: 
function! s:class.UpdateOneTag(sTag) dict abort "{{{
    let l:sTag = tolower(a:sTag)
    if has_key(self.tagsave, l:sTag)
        return 0
    endif

    " note entry of current note
    let l:sNoteName = self.GetNoteName()
    let l:sTitle = self.GetNoteTitle()
    let l:sNoteEntry = l:sNoteName . "\t" . l:sTitle

    let l:pTagDir = self.notebook.Tagdir()
    if !isdirectory(l:pTagDir)
        call mkdir(l:pTagDir, 'p')
    endif

    " read in old notelist of that tag
    let l:pTagFile = l:pTagDir . '/' . l:sTag . '.tag'
    if filereadable(l:pTagFile)
        let l:lsNote = readfile(l:pTagFile)
    else
        let l:lsNote = []
    endif

    let l:iFound = match(l:lsNote, '^' . l:sNoteName)
    let l:bFound = l:iFound != -1

    let l:iRet = 0
    if l:bFound == v:false
        call add(l:lsNote, l:sNoteEntry)

        " complex tag, treat as path
        if match(l:sTag, '/') != -1
            let l:pTagDir = fnamemodify(l:pTagFile, ':p:h')
            if !isdirectory(l:pTagDir)
                call mkdir(l:pTagDir, 'p')
            endif
        endif

        let l:iRet = writefile(l:lsNote, l:pTagFile)
        if l:iRet == 0
            :LOG 'update tag file: ' . l:sTag
        else
            :LOG 'fail to update tag file: ' . l:sTag
        endif
    endif

    if l:iRet == 0
        let self.tagsave[l:sTag] = v:true
    endif
    return l:iRet
endfunction "}}}

" RemoveUpdateTag:
function! s:class.RemoveUpdateTag(sTag) dict abort "{{{
    let l:sTag = tolower(a:sTag)
    let l:sNoteName = self.GetNoteName()

    let l:pTagDir = self.notebook.Tagdir()
    let l:pTagFile = l:pTagDir . '/' . l:sTag . '.tag'
    if !filereadable(l:pTagFile)
        return 0
    endif

    let l:lsNote = readfile(l:pTagFile)
    let l:iFound = match(l:lsNote, '^' . l:sNoteName)
    if l:iFound == -1
        return 0
    endif

    call remove(l:lsNote, l:iFound)
    :LOG 'remove tag: ' . a:sTag
    let l:iRet = writefile(l:lsNote, l:pTagFile)
    if l:iRet == 0 && has_key(self.tagsave, l:sTag)
        remove(self.tagsave, l:sTag)
    endif

    return l:iRet
endfunction "}}}

" AddTag: 
function! s:class.AddTag(...) dict abort "{{{
    let l:list = module#less#list#import()
    let l:lsTag = l:list.Flat(a:000)
    for l:sTag in l:lsTag
        call self._AddTag(l:sTag)
    endfor
endfunction "}}}

" _AddTag: 
function! s:class._AddTag(sTag) dict abort "{{{
    let l:lsTag = self.GetTagList()
    call map(l:lsTag, 'tolower(v:val)')
    if index(l:lsTag, tolower(a:sTag)) != -1
        :WLOG 'tag already in this note: ' . a:sTag
        return 0
    endif

    let l:sTag = printf('`%s`', a:sTag)
    let l:sLine = getline(2)
    if l:sLine =~ '^\s*`.\+`'
        call setline(2, l:sLine . ' ' . l:sTag)
    else
        call append(1, l:sTag)
    endif

    return self.UpdateOneTag(l:sTag)
endfunction "}}}

" RemoveTag: 
function! s:class.RemoveTag(...) dict abort "{{{
    let l:list = module#less#list#import()
    let l:lsTag = l:list.Flat(a:000)
    for l:sTag in l:lsTag
        call self._RemoveTag(l:sTag)
    endfor
endfunction "}}}

" _RemoveTag: 
function! s:class._RemoveTag(sTag) dict abort "{{{
    let l:lsTag = self.GetTagList()
    call map(l:lsTag, 'tolower(v:val)')
    if index(l:lsTag, tolower(a:sTag)) == -1
        :WLOG 'tag note in this note: ' . a:sTag
        return 0
    endif
    return self.RemoveUpdateTag(l:sTag)
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
