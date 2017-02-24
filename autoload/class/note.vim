" Class: class#note
" Author: lymslive
" Description: a class that represent a note file
" Create: 2017-02-17
" Modify: 2017-02-17

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" constant value
let s:HEADLINE = 10

" CLASS:
let s:class = class#old()
let s:class._name_ = 'class#note'
let s:class._version_ = 1

" the full path name of note
let s:class.path = ''

function! class#note#class() abort "{{{
    return s:class
endfunction "}}}

" NEW:
function! class#note#new(...) abort "{{{
    let l:obj = copy(s:class)
    call l:obj._new_(a:000)
    return l:obj
endfunction "}}}

" CTOR:
function! class#note#ctor(this, argv) abort "{{{
    if len(a:argv) > 0 && !empty(a:argv[0])
        let a:this.path = a:argv[0]
    else
        echoerr 'class#note expect a note file path to construct objcet'
    endif
endfunction "}}}

" OLD:
function! class#note#old() abort "{{{
    let l:class = copy(s:class)
    call l:class._old_()
    return l:class
endfunction "}}}

" ISOBJECT:
function! class#note#isobject(that) abort "{{{
    return s:class._isobject_(a:that)
endfunction "}}}

" IsinBook: check if this note file is in a notebook directory
function! s:class.IsinBook(jNoteBook) dict abort "{{{
    if match(self.path, '^' . a:jNoteBook.Datedir()) != -1
        return v:true
    else
        return v:false
    endif
endfunction "}}}

" GetNoteName: 
function! s:class.GetNoteName() dict abort "{{{
    return fnamemodify(self.path, ':t:r')
endfunction "}}}

" GetHeadLine: 
function! s:class.GetHeadLine(iMaxLine) dict abort "{{{
    if !filereadable(self.path)
        return []
    else
        return readfile(self.path, '', 0 + a:iMaxLine)
    endif
endfunction "}}}

" GetNoteTitle: 
function! s:class.GetNoteTitle() dict abort "{{{
    let l:lsLine = self.GetHeadLine(1)
    if empty(l:lsLine)
        return ''
    endif

    let l:sFirst = l:lsLine[0]
    let l:sTitle = substitute(l:sFirst, '^\s*#\s*', '', '')

    return l:sTitle
endfunction "}}}

" GetTagLine: 
" return the note tags in one string, include `` quote each
function! s:class.GetTagLine() dict abort "{{{
    let l:lsLine = self.GetHeadLine(s:HEADLINE)
    return self.GetTagLine_(l:lsLine)
endfunction "}}}

" GetTagLine_: private method to get tag info from string list
function! s:class.GetTagLine_(lsLine) dict abort "{{{
    let l:lsTagLine = []

    let l:bTagOn = v:false
    for l:sLine in a:lsLine
        if strlen(l:sLine) < 3
            continue
        endif

        if l:sLine[0] == '`' && l:sLine[1] != '`'
            if !l:bTagOn
                let l:bTagOn = v:true
            endif
            call add(l:lsTagLine, l:sLine)
        else
            if l:bTagOn
                break
            endif
        endif
    endfor

    return join(l:lsTagLine)
endfunction "}}}

" GetTagList: 
" return a list of tags, exclude `` quote each
function! s:class.GetTagList() dict abort "{{{
    let l:lsLine = self.GetHeadLine(s:HEADLINE)
    return self.GetTagList_(l:lsLine)
endfunction "}}}

" GetTagList_: private method to get tag info from string list
function! s:class.GetTagList_(lsLine) dict abort "{{{
    let l:lsTag = []

    let l:bTagOn = v:false
    for l:sLine in a:lsLine
        if match(l:sLine, '^\s*`') != -1
            if !l:bTagOn
                let b:TagOn = v:true
            endif 
            let l:lsTmp = self.FindTags_(l:sLine)
            if !empty(l:lsTmp)
                call extend(l:lsTag, l:lsTmp)
            endif
        else
            if l:bTagOn
                break
            endif
        endif
    endfor

    return l:lsTag
endfunction "}}}

" FindTags_: private method to get tag info from one string
function! s:class.FindTags_(sLine) dict abort "{{{
    if empty(a:sLine)
        return []
    endif

    let l:lsTag = []

    let l:quote_stack = []
    let l:quote_left = -1
    let l:quote_right = -1
    for l:idx in range(len(a:sLine))
        if a:sLine[l:idx] != '`'
            continue
        endif

        if empty(l:quote_stack)
            call add(l:quote_stack, l:idx)
        else
            let l:quote_left = remove(l:quote_stack, -1)
            let l:quote_right = l:idx
            if l:quote_left == -1 || l:quote_right == -1
                continue
            elseif l:quote_right - l:quote_left <= 1
                continue
            else
                let l:sTag = strpart(a:sLine, l:quote_left+1, l:quote_right-l:quote_left - 1)
                call add(l:lsTag, l:sTag)
            endif
        endif
    endfor

    return l:lsTag
endfunction "}}}

" LOAD:
let s:load = 1
:DLOG 'class#note is loading ...'
function! class#note#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1) && exists('s:load')
        unlet s:load
        return 0
    endif
    return s:load
endfunction "}}}

" TEST:
function! class#note#test(...) abort "{{{
    return 0
endfunction "}}}
