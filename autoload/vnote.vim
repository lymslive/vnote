" vnote tools
" Author: lymslive
" Date: 2017-02-17

let s:default_notebook = "~/notebook"
if exists('g:vnote_default_notebook')
    let s:default_notebook = g:vnote_default_notebook
endif

let s:current_notebook = expand(s:default_notebook)

" GetNoteBook: 
let s:jNoteBook = class#notebook#new(s:current_notebook)
function! vnote#GetNoteBook() "{{{
    return s:jNoteBook
endfunction "}}}

" OpenNoteBook: open another notebook overide the default
function! vnote#OpenNoteBook(...) "{{{
    if a:0 == 0
        echo 'current notebook: ' . s:dNoteBook.basedir
        return 0
    endif

    let l:pBasedir = expand(a:1)
    if !isdirectory(l:pBasedir)
        echoerr a:pBasedir . 'is not a valid directory?'
        return -1
    endif

    if match(l:pBasedir, '/$') != -1
        let l:pBasedir = substitute(l:pBasedir, '/$', '', '')
    endif

    call s:jNoteBook.SetBasedir(l:pBasedir)
    echo 'open notebook: ' . l:pBasedir
    return 0
endfunction "}}}

" NewNote: edit new note of today
function! vnote#hNoteNew(...) "{{{
    let l:sDatePath = strftime("%Y/%m/%d")

    if a:0 > 0 && a:1 ==# '-'
        let l:bPrivate = v:true
    else
        let l:bPrivate = v:false
    endif

    let l:pNoteFile = s:jNoteBook.AllocNewNote(l:sDatePath, l:bPrivate)
    let l:pDirectory = s:jNoteBook.Notedir(l:sDatePath)
    if !isdirectory(l:pDirectory)
        call mkdir(l:pDirectory, 'p')
    endif

    execute 'edit ' . l:pNoteFile

    " pre-insert tow lines
    call append(0, '# note title')
    if l:bPrivate
        call append(1, '`-`')
    else
        call append(1, '`+`')
    endif

    " put cursor on title
    normal ggw
endfunction "}}}

" EditNote: 
function! vnote#hNoteEdit(...) "{{{
    if a:0 >= 1
        let l:sDatePath = a:1
    else
        let l:sDatePath = strftime("%Y/%m/%d")
    endif

    let l:pDirectory = s:jNoteBook.Notedir(l:sDatePath)
    if empty(l:pDirectory)
        return 0
    endif

    let l:pNoteFile = s:jNoteBook.GetLastNote(l:sDatePath)
    if !empty(l:pNoteFile)
        if !isdirectory(l:pDirectory)
            call mkdir(l:pDirectory, 'p')
        endif
        execute 'edit ' . l:pNoteFile
    endif
endfunction "}}}

