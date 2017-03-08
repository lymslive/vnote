" Class: class#notefile
" Author: lymslive
" Description: a note file with RW support, not load in buffer
" Create: 2017-03-08
" Modify: 2017-03-08

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
let s:class = note#old()
let s:class._name_ = 'class#notefile'
let s:class._version_ = 1

" the content of note file
let s:class.content = []

function! class#notefile#class() abort "{{{
    return s:class
endfunction "}}}

" NEW:
function! class#notefile#new(...) abort "{{{
    let l:obj = copy(s:class)
    call l:obj._new_(a:000)
    return l:obj
endfunction "}}}

" CTOR:
function! class#notefile#ctor(this, argv) abort "{{{
    let l:Suctor = s:class._suctor_()
    call l:Suctor(a:this, a:argv)

    if filereadable(a:this.path)
        let a:this.content = readfile(a:this.path)
    else
        let a:this.content = 0
        :ELOG 'cannot read in note file: ' . a:this.path
    endif
endfunction "}}}

" ISOBJECT:
function! class#notefile#isobject(that) abort "{{{
    return s:class._isobject_(a:that)
endfunction "}}}

" GetHeadLine: 
function! s:class.GetHeadLine(iMaxLine) dict abort "{{{
    if empty(self.content)
        return []
    else
        return self.content[1 : a:iMaxLine]
    endif
endfunction "}}}

" AddTag: 
function! s:class.AddTag(sTag) dict abort "{{{
    let l:sTag = printf('`%s`', a:sTag)

    let l:lsTagLine = self.LocateTagLine_()
    let l:bFound = v:false
    for l:dEntry in l:lsTagLine
        let l:sLine = l:dEntry['line_str']
        if l:sLine =~? l:sTag
            let l:bFound = v:true
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

    let l:bFound = v:false
    for l:dEntry in l:lsTagLine
        let l:sLine = l:dEntry['line_str']
        if l:sLine =~? l:sTag
            let l:bFound = v:true
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
    let l:sLine = substitute(l:sLine, 'l:sTag' . '\c', '', '')
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

    let l:bFound = v:false
    for l:dEntry in l:lsTagLine
        let l:sLine = l:dEntry['line_str']
        if l:sLine =~? l:sTag
            let l:bFound = v:true
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
    let l:sLine = substitute(l:sLine, 'l:sTag' . '\c', l:sNew, '')
    let self.content[l:iLine] = l:sLine

    return self.SaveFile()
endfunction "}}}

" SaveFile: 
function! s:class.SaveFile() dict abort "{{{
    return writefile(self.content, self.path)
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
    return 0
endfunction "}}}
