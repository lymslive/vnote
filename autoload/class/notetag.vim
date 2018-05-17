" Class: class#notetag
" Author: lymslive
" Description: denotes a tagfile of notebook
" Create: 2017-03-08
" Modify: 2017-08-04

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" constant
let s:NOTEBOOK = vnote#GetNoteBook()

" CLASS:
let s:class = class#old()
let s:class._name_ = 'class#notetag'
let s:class._version_ = 1

" which notebook belong to
let s:class.notebook = {}

" the tag name
let s:class.tag = ''

function! class#notetag#class() abort "{{{
    return s:class
endfunction "}}}

" NEW:
function! class#notetag#new(...) abort "{{{
    let l:obj = class#new(s:class, a:000)
    return l:obj
endfunction "}}}

" CTOR: (tag, notebook)
function! class#notetag#ctor(this, ...) abort "{{{
    if a:0 < 1
        :ELOG 'expect a tagname'
        return -1
    endif
    let a:this.tag = a:1

    if a:0 < 2
        let a:this.notebook = s:NOTEBOOK
    else
        let a:this.notebook = a:2
    endif

    return 0
endfunction "}}}

" ISOBJECT:
function! class#notetag#isobject(that) abort "{{{
    return class#isobject(s:class, a:that)
endfunction "}}}

" OLD:
function! class#notetag#old() abort "{{{
    let l:class = class#old(s:class)
    return l:class
endfunction "}}}

" GetTagFile: 
function! s:class.GetTagFile() dict abort "{{{
    let l:rtp = module#less#rtp#import()
    return self.notebook.Tagdir() . l:rtp.separator . self.tag . '.tag'
endfunction "}}}
" string: as the full path of tagfile
function! s:class.string() dict abort "{{{
    return self.GetTagFile()
endfunction "}}}

" number: as the count of note having this tag
" or count of lines of the tagfile
function! s:class.number() dict abort "{{{
    let l:pTagFile = self.string()
    if !filereadable(l:pTagFile)
        return 0
    endif

    if executable('wc') == 1
        return 0 + system('wc -l ' . l:pTagFile)
    else
        let l:lsContent = readfile(l:pTagFile)
        return len(l:lsContent)
    endif
endfunction "}}}

" list: the list of content lines
function! s:class.list() dict abort "{{{
    let l:pTagFile = self.string()
    if !filereadable(l:pTagFile)
        return []
    else
        return readfile(l:pTagFile)
    endif
endfunction "}}}

" Delete: delete a tag
function! s:class.Delete() dict abort "{{{
    let l:pTagFile = self.string()
    let l:lsContent = self.list()

    for l:sEntry in l:lsContent
        let l:jNoteEntry = class#notename#new(l:sEntry)
        if empty(l:jNoteEntry.string())
            continue
        endif

        let l:pFileName = l:jNoteEntry.GetFullPath(self.notebook)
        let l:jNoteFile = class#notefile#new(l:pFileName)
        call l:jNoteFile.DeleteTag(self.tag)
    endfor

    return delete(l:pTagFile)
endfunction "}}}

" Rename: rename to a new name
function! s:class.Rename(sNewTag) dict abort "{{{
    let l:pTagFile = self.string()
    let l:lsContent = self.list()
    for l:sEntry in l:lsContent
        let l:jNoteEntry = class#notename#new(l:sEntry)
        if empty(l:jNoteEntry.string())
            continue
        endif

        let l:pFileName = l:jNoteEntry.GetFullPath(self.notebook)
        let l:jNoteFile = class#notefile#new(l:pFileName)
        call l:jNoteFile.RenameTag(self.tag, a:sNewTag)
    endfor

    let l:jNewTag = class#notetag#new(a:sNewTag)
    let l:pNewFile = l:jNewTag.string()
    return rename(l:pTagFile, l:pNewFile)
endfunction "}}}

" Merge: merge two tags
function! s:class.Merge(jAnother) dict abort "{{{
    if !class#notetag#isobject(a:jAnother)
        :DLOG 'notetag.Merge() expect another object'
        return -1
    endif

    let l:pTagFile = self.string()
    let l:lsContent = self.list()

    let l:pThatFile = a:jAnother.string()
    let l:lsThat = a:jAnother.list()
    for l:sEntry in l:lsThat
        let l:jNoteEntry = class#notename#new(l:sEntry)
        if empty(l:jNoteEntry.string())
            continue
        endif

        let l:pFileName = l:jNoteEntry.GetFullPath(a:jAnother.notebook)
        let l:jNoteFile = class#notefile#new(l:pFileName)
        call l:jNoteFile.AddTag(self.tag)
    endfor

    call extend(l:lsContent, l:lsThat)
    return writefile(l:lsContent, l:pTagFile)
endfunction "}}}

" UpdateEntry: add a note entry to this tag file
" > a:1, bForceSave, replace the old entry with the same note name
function! s:class.UpdateEntry(sNoteEntry, ...) dict abort "{{{
    let l:lsPart = split(a:sNoteEntry, "\t")
    if len(l:lsPart) < 2
        :ELOG 'It seems not valid note entry: ' . sNoteEntry
        return -1
    endif

    let l:sNoteName = l:lsPart[0]
    let l:bForceSave = get(a:000, 0, v:false)

    let l:lsNote = self.list()
    let l:iFound = match(l:lsNote, '^' . l:sNoteName)
    if l:iFound == -1
        call add(l:lsNote, a:sNoteEntry)
    else
        " already in tag file
        if empty(l:bForceSave)
            return 0
        endif
        let l:lsNote[l:iFound] = l:sNoteEntry
    endif

    return self.Write(l:lsNote)
endfunction "}}}

" RemoveEntry: remove a entry from this tag
" > a:sNoteEntry, can be only the leading sNoteName
function! s:class.RemoveEntry(sNoteEntry) dict abort "{{{
    let l:lsPart = split(a:sNoteEntry, "\t")
    let l:sNoteName = l:lsPart[0]

    let l:lsNote = self.list()
    let l:iFound = match(l:lsNote, '^' . l:sNoteName)
    if l:iFound == -1
        return 0
    endif

    call remove(l:lsNote, l:iFound)
    return self.Write(l:lsNote)
endfunction "}}}

" Write: 
function! s:class.Write(lsNote) dict abort "{{{
    let l:pTagFile = self.GetTagFile()
    let l:pTagDir = fnamemodify(l:pTagFile, ':p:h')
    if !isdirectory(l:pTagDir)
        call mkdir(l:pTagDir, 'p')
    endif

    return writefile(a:lsNote, l:pTagFile)
endfunction "}}}

" LOAD:
let s:load = 1
:DLOG '-1 class#notetag is loading ...'
function! class#notetag#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1) && exists('s:load')
        unlet s:load
        return 0
    endif
    return s:load
endfunction "}}}

" TEST:
function! class#notetag#test(...) abort "{{{
    let l:jTag = class#notetag#new('vnote')
    echo l:jTag.string()
    echo l:jTag.number()
    let l:lsContent = l:jTag.list()
    for l:sLine in l:lsContent
        echo l:sLine
    endfor
    return 0
endfunction "}}}
