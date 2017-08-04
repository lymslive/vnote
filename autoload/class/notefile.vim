" Class: class#notefile
" Author: lymslive
" Description: a note file with RW support, not load in buffer
" Create: 2017-03-08
" Modify: 2017-08-04

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
let s:class = class#note#old()
let s:class._name_ = 'class#notefile'
let s:class._version_ = 1

" the content of note file
let s:class.content = []

function! class#notefile#class() abort "{{{
    return s:class
endfunction "}}}

" NEW:
function! class#notefile#new(...) abort "{{{
    let l:obj = class#new(s:class, a:000)
    return l:obj
endfunction "}}}

" CTOR:
function! class#notefile#ctor(this, ...) abort "{{{
    let l:Suctor = class#Suctor(s:class)
    call l:Suctor(a:this, a:argv)
    call call(l:Suctor, extend([a:this], a:000))

    call a:this.LoadFile()
endfunction "}}}

" ISOBJECT:
function! class#notefile#isobject(that) abort "{{{
    return class#isobject(s:class, a:that)
endfunction "}}}

" GetHeadLine: 
function! s:class.GetHeadLine(iMaxLine) dict abort "{{{
    if empty(self.content)
        return []
    else
        return self.content[0 : a:iMaxLine-1]
    endif
endfunction "}}}

" AddTag: 
function! s:class.AddTag(sTag) dict abort "{{{
    let l:sTag = printf('`%s`', a:sTag)

    let l:lsTagLine = self.LocateTagLine_()
    let l:bFound = g:class#FALSE
    for l:dEntry in l:lsTagLine
        let l:sLine = l:dEntry['line_str']
        if l:sLine =~? l:sTag
            let l:bFound = g:class#TRUE
            break
        endif
    endfor

    " already have the tag, nothing to do
    if l:bFound
        return 0
    endif

    if empty(self.content)
        " not any tagline before, insert in the second line
        call insert(self.content, l:sTag, 1)
    else
        " add to the first tagline
        let l:dEntry = l:lsTagLine[0]
        let l:iLine = l:dEntry['line_no']
        let l:sLine = l:dEntry['line_str']
        let self.content[l:iLine] = l:sLine . ' ' . l:sTag
    endif

    return self.SaveFile()
endfunction "}}}

" DeleteTag: 
function! s:class.DeleteTag(sTag) dict abort "{{{
    let l:sTag = printf('`%s`', a:sTag)

    let l:lsTagLine = self.LocateTagLine_()
    if empty(l:lsTagLine)
        return 0
    endif

    let l:bFound = g:class#FALSE
    for l:dEntry in l:lsTagLine
        let l:sLine = l:dEntry['line_str']
        if l:sLine =~? l:sTag
            let l:bFound = g:class#TRUE
            break
        endif
    endfor

    " not have the tag, nothing to do
    if !l:bFound
        return 0
    endif

    " ?? dose l:dEntry still existed here
    let l:iLine = l:dEntry['line_no']
    let l:sLine = l:dEntry['line_str']
    let l:sLine = substitute(l:sLine, l:sTag . '\c', '', '')
    let self.content[l:iLine] = l:sLine

    return self.SaveFile()
endfunction "}}}

" RenameTag: 
function! s:class.RenameTag(sTag, sNew) dict abort "{{{
    let l:sTag = printf('`%s`', a:sTag)
    let l:sNew = printf('`%s`', a:sNew)

    let l:lsTagLine = self.LocateTagLine_()
    if empty(l:lsTagLine)
        return 0
    endif

    let l:bFound = g:class#FALSE
    for l:dEntry in l:lsTagLine
        let l:sLine = l:dEntry['line_str']
        if l:sLine =~? l:sTag
            let l:bFound = g:class#TRUE
            break
        endif
    endfor

    " not have the tag, nothing to do
    if !l:bFound
        return 0
    endif

    " ?? dose l:dEntry still existed here
    let l:iLine = l:dEntry['line_no']
    let l:sLine = l:dEntry['line_str']
    let l:sLine = substitute(l:sLine, l:sTag . '\c', l:sNew, '')
    let self.content[l:iLine] = l:sLine

    return self.SaveFile()
endfunction "}}}

" SaveFile: 
function! s:class.SaveFile() dict abort "{{{
    return writefile(self.content, self.path)
endfunction "}}}

" LoadFile: 
function! s:class.LoadFile() dict abort "{{{
    if filereadable(self.path)
        let self.content = readfile(self.path)
    else
        let self.content = []
        :ELOG 'cannot read in note file: ' . self.path
    endif
    return len(self.content)
endfunction "}}}

" LOAD:
let s:load = 1
:DLOG '-1 class#notefile is loading ...'
function! class#notefile#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1) && exists('s:load')
        unlet s:load
        return 0
    endif
    return s:load
endfunction "}}}

" TEST:
function! class#notefile#test(...) abort "{{{
    let l:jNoteEntry = class#notename#new('20170226_1')
    let l:pFileName = l:jNoteEntry.GetFullPath(vnote#GetNoteBook())
    let l:jNoteFile = class#notefile#new(l:pFileName)
    call l:jNoteFile.DeleteTag('add')
    echo join(l:jNoteFile.content, "\n")

    return l:jNoteFile
endfunction "}}}
