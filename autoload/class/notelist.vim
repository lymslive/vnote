" Class: class#notelist
" Author: lymslive
" Description: notelist manager
" Create: 2017-02-16
" Modify: 2017-03-22

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
let s:class = class#old()
let s:class._name_ = 'class#notelist'
let s:class._version_ = 1

" which notebook this list belong to
let s:class.notebook = {}

" the argument of note-list
let s:class.argv = []

function! class#notelist#class() abort "{{{
    return s:class
endfunction "}}}

" NEW:
function! class#notelist#new(...) abort "{{{
    let l:obj = copy(s:class)
    call l:obj._new_(a:000)
    return l:obj
endfunction "}}}

" CTOR:
function! class#notelist#ctor(this, argv) abort "{{{
    if len(a:argv) > 0
        call a:this.SetNoteBook(a:argv[0])
    else
        echoerr 'expect a class#notebook to construct a class#notelist object'
    endif
    let a:this.argv = []
endfunction "}}}

" SetNoteBook: 
function! s:class.SetNoteBook(jNoteBook) dict abort "{{{
    if class#notebook#isobject(a:jNoteBook)
        let self.notebook = a:jNoteBook
        return 0
    else
        echoerr 'expect an object of class#notebook'
        return -1
    endif
endfunction "}}}

" RefreshList: Interface of NoteList command, fresh the notelist
" > a:1, force re-list even if argv is the same as last
function! s:class.RefreshList(argv, ...) dict abort "{{{
    if a:argv ==# self.argv && empty(get(a:000, 0, class#FALSE))
        return 0
        :LOG 'directly redraw as same argv'
    endif
    let l:lsContent = self.GatherContent(a:argv)
    return self.RedrawContent(l:lsContent)
endfunction "}}}

" GatherContent: parse argv and then configue out list content
function! s:class.GatherContent(argv) dict abort "{{{
    if empty(a:argv) || type(a:argv) !=# type([])
        return []
    endif

    let l:lsContent = []

    let l:cMode = get(a:argv, 0, '')
    let l:sArg = get(a:argv, 1, '')

    if l:cMode !~# '^-'
        if empty(a:argv[0])
            let l:cMode = '-d'
            let l:sArg = ''
        elseif a:argv[0] =~ self.notebook.pattern.dateYear
            let l:cMode = '-d'
            let l:sArg = a:argv[0]
        else
            let l:cMode = '-t'
            let l:sArg = a:argv[0]
        endif
    endif

    if l:cMode =~# '-a'
        let l:sArg = ''
        let l:jScope = class#notescope#new(self.notebook)
        let l:lsContent = l:jScope.list()

    elseif l:cMode =~# '-d'
        if empty(l:sArg)
            let l:sArg = strftime("%Y/%m/%d")
        endif
        let l:jScope = class#notescope#date#new(self.notebook, l:sArg)
        let l:lsContent = l:jScope.list()

    elseif l:cMode =~# '-t'
        if empty(l:sArg)
            :ELOG 'NoteList -t expect a tagname'
            return []
        endif
        let l:pTagDir = self.notebook.Tagdir()
        let l:jScope = class#notescope#tag#new(self.notebook, l:pTagDir, l:sArg)
        let l:lsContent = l:jScope.list()

    elseif l:cMode =~# '-m'
        if empty(l:sArg)
            let l:sArg = 'mru'
        endif
        let l:pTagDir = self.notebook.Markdir()
        let l:jScope = class#notescope#tag#new(self.notebook, l:pTagDir, l:sArg)
        let l:lsContent = l:jScope.list()

    elseif l:cMode =~# '-D'
        let l:jBrowse = class#notebrowse#date#new(self.notebook, l:sArg)
        if l:jBrowse.TransferScope()
            let l:cMode = '-d'
            let l:jScope = class#notescope#date#new(self.notebook, l:sArg)
            let l:lsContent = l:jScope.list()
        else
            let l:lsContent = l:jBrowse.list()
        endif

    elseif l:cMode =~# '-T'
        let l:pTagDir = self.notebook.Tagdir()
        let l:jBrowse = class#notebrowse#tag#new(self.notebook, l:pTagDir, l:sArg)
        if l:jBrowse.TransferScope()
            let l:cMode = '-t'
            let l:jScope = class#notescope#tag#new(self.notebook, l:pTagDir, l:sArg)
            let l:lsContent = l:jScope.list()
        else
            let l:lsContent = l:jBrowse.list()
        endif

    elseif l:cMode =~# '-M'
        let l:pTagDir = self.notebook.Markdir()
        let l:jBrowse = class#notebrowse#tag#new(self.notebook, l:pTagDir, l:sArg)
        if l:jBrowse.TransferScope()
            let l:cMode = '-m'
            let l:jScope = class#notescope#tag#new(self.notebook, l:pTagDir, l:sArg)
            let l:lsContent = l:jScope.list()
        else
            let l:lsContent = l:jBrowse.list()
        endif

    else
        :ELOG 'unknow NoteList mode, accept [aDTMdtm]'
    endif

    let self.argv = [l:cMode, l:sArg]
    return l:lsContent
endfunction "}}}

" RedrawContent: update the notelist buffer
function! s:class.RedrawContent(lsContent) dict abort "{{{
    if expand('%:p') !=# self.notebook.GetListerName()
        execute 'edit ' . self.notebook.GetListerName()
        :ELOG 'try to write list content to non-lister buffer'
    endif

    setlocal modifiable
    " clear old content
    :1,$delet

    " set buffer content
    call setline(1, '$ NoteBook ' . self.notebook.basedir)
    call setline(2, '$ NoteList ' . join(self.argv))
    call setline(3, self.GetSepapateLine())
    call append(line('$'), a:lsContent)

    " put cursor
    normal! 4G
    let l:dConfig = vnote#GetConfig()
    let l:iPos = get(l:dConfig, 'list_default_cursor', 1)
    if l:iPos ==# '$'
        normal! G
    else
        let l:iDown = 0 + l:iPos - 1
        if l:iDown > 0
            execute 'normal! ' . l:iDown . 'j'
        endif
    endif

    " set type for new buffer
    if &filetype !=# 'notelist'
        setlocal filetype=notelist
        setlocal buftype=nofile
        setlocal bufhidden=hide
        setlocal noswapfile
        setlocal nobuflisted
    endif

    setlocal nomodifiable
    return 0
endfunction "}}}

" GetSepapateLine: 
function! s:class.GetSepapateLine() dict abort "{{{
    let l:len = 70
    if winwidth(0) < l:len
        let l:len = winwidth(0)
    endif
    return repeat('=', l:len)
endfunction "}}}

" AjustSeparateLine: 
function! s:class.AjustSeparateLine() dict abort "{{{
    if line('$') >= 3 && getline(3) =~ '^#\+'
        let l:sNewLine = self.GetSepapateLine()
        if len(l:sNewLine) != len(getline(3))
            setlocal modifiable
            call setline(3, l:sNewLine)
            setlocal nomodifiable
        endif
    endif
    return 0
endfunction "}}}

" BackList: 
function! s:class.BackList() dict abort "{{{
    let l:cMode = self.argv[0]
    let l:cMode = substitute(l:cMode, '^-', '', '')
    if stridx('TDMtdm', l:cMode) < 0
        :LOG '[notelist] can only back in -DTdt modes'
        return -1
    endif

    let l:sArg = self.argv[1]
    if empty(l:sArg)
        :LOG '[notelist] alread in the top level'
        return 0
    endif

    let l:sNewArg = substitute(l:sArg, '[^/]*/\?$', '', '')
    let l:lsArgv = [toupper(self.argv[0]), l:sNewArg]
    call self.RefreshList(l:lsArgv)
    call search('^' . l:sArg, 'w')
endfunction "}}}

" LOAD:
let s:load = 1
:DLOG 'class#notelist is loading ...'
function! class#notelist#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1) && exists('s:load')
        unlet s:load
        return 0
    endif
    return s:load
endfunction "}}}

" TEST:
function! class#notelist#test(...) abort "{{{
    return 0
endfunction "}}}
