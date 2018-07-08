" Class: class#notebuff
" Author: lymslive
" Description: current buffer as note file
" Create: 2017-02-17
" Modify: 2018-06-01

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
let s:class = class#note#old()
let s:class._name_ = 'class#notebuff'
let s:class._version_ = 1

let s:class.saved = v:false

function! class#notebuff#class() abort "{{{
    return s:class
endfunction "}}}

" NEW:
function! class#notebuff#new(...) abort "{{{
    let l:obj = class#new(s:class, a:000)
    return l:obj
endfunction "}}}

" CTOR:
function! class#notebuff#ctor(this, ...) abort "{{{
    let l:Suctor = class#Suctor(s:class)
    let l:pFileName = expand('%:p')
    if a:0 > 0
        call l:Suctor(a:this, l:pFileName, a:1)
    else
        call l:Suctor(a:this, l:pFileName)
    endif
endfunction "}}}

" ISOBJECT:
function! class#notebuff#isobject(that) abort "{{{
    return class#isobject(s:class, a:that)
endfunction "}}}

" GetHeadLine:  overide base class
function! s:class.GetHeadLine(iMaxLine) dict abort "{{{
    return getline(1, a:iMaxLine)
endfunction "}}}

" MarkSaved: 
function! s:class.MarkSaved(...) dict abort "{{{
    let l:saved = get(a:000, 0, v:true)
    let self.saved = l:saved
endfunction "}}}

" SaveNote: auto save cache and tag file
" > a:1 force save
function! s:class.SaveNote(...) dict abort "{{{
    if a:0 > 0 && !empty(a:1)
        let self.saved = v:false
    endif

    if self.saved
        return 0
    endif

    let l:iErr = 0
    let l:iErr += self.PushMru()

    if g:vnote#perlx#enable
        let l:iErr += vnote#perlx#OnSave(self.GetNoteName())
    else
        let l:iErr += self.UpdateCache()
        let l:iErr += self.UpdateTagFile()
    endif

    let self.saved = v:true
    return l:iErr
endfunction "}}}

" PushMru: 
function! s:class.PushMru() dict abort "{{{
    let l:sNoteEntry = self.GetNoteEntry()
    call self.notebook.AddMru(l:sNoteEntry)
    return 0
endfunction "}}}

" UpdateCache: 
function! s:class.UpdateCache() dict abort "{{{
    " may have zero time bug
    " use :NoteSave y
    if !self.IsTodayNote() " && self.forcesave !~? '^y'
        return 0
    endif

    let l:sNoteEntry = self.GetNoteEntry()
    let l:iErr = self.notebook.SaveCache(l:sNoteEntry)
    return l:iErr
endfunction "}}}

" IsTodayNote: 
function! s:class.IsTodayNote() dict abort "{{{
    let l:sNoteName = self.GetNoteName()
    let l:sToday = strftime('%Y%m%d')
    if l:sNoteName =~# '^' . l:sToday
        return v:true
    else
        return v:false
    endif
endfunction "}}}

" UpdateTagFile: 
function! s:class.UpdateTagFile() dict abort "{{{
    let l:lsTag = self.GetTagList()
    if empty(l:lsTag)
        return 0
    endif

    let l:config = vnote#GetConfig()
    let l:iCount = 0
    let l:iEnd = len(l:lsTag)

    for l:sTag in l:lsTag
        if l:sTag ==# '-'
            if !l:config.auto_save_minus_tag
                continue
            endif
        elseif l:sTag ==# '+'
            if !l:config.auto_save_plus_tag
                continue
            endif
        endif

        let l:iRet = self.UpdateOneTag(l:sTag)
        if l:iRet != 0
            return l:iRet
        endif

        let l:iCount += 1
        if l:iCount >= l:config.note_file_max_tags
            break
        endif
    endfor

    if l:sTag !=# l:lsTag[-1]
        :WLOG 'too many tags, the last few tags donot save'
    endif

    let l:iWin = vnote#GotoNoteWindow()
    if l:iWin > 0 && exists('b:jNoteList')
        call b:jNoteList.OnCheckTime()
    endif

    return 0
endfunction "}}}

" UpdateOneTag: 
function! s:class.UpdateOneTag(sTag) dict abort "{{{
    let l:sTag = tolower(a:sTag)

    " note entry of current note
    let l:sNoteEntry = self.GetNoteEntry()
    let l:jNoteTag = class#notetag#new(l:sTag)

    let l:iRet = l:jNoteTag.UpdateEntry(l:sNoteEntry, 1)
    if l:iRet == 0
        :DLOG 'update tag file: ' . l:sTag
    else
        :DLOG 'fail to update tag file: ' . l:sTag
    endif

    return l:iRet
endfunction "}}}

" RemoveUpdateTag:
function! s:class.RemoveUpdateTag(sTag) dict abort "{{{
    let l:sTag = tolower(a:sTag)
    " let l:sNoteEntry = self.GetNoteEntry()
    let l:sNoteName = self.GetNoteName()

    let l:jNoteTag = class#notetag#new(l:sTag)
    let l:iRet = l:jNoteTag.RemoveEntry(l:sNoteName)
    return l:iRet
endfunction "}}}

" AddTag: 
function! s:class.AddTag(...) dict abort "{{{
    let l:list = class#less#list#export()
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

    return 0
    " delay to autosave tagfile when write
    " return self.UpdateOneTag(l:sTag)
endfunction "}}}

" RemoveTag: 
function! s:class.RemoveTag(...) dict abort "{{{
    let l:list = class#less#list#export()
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
    return self.RemoveUpdateTag(a:sTag)
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
