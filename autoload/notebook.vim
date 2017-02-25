" File: notebook
" Author: lymslive
" Description: manage notebook
" Create: 2017-02-24
" Modify: 2017-02-24

" import s:jNoteBook from vnote
let s:jNoteBook = vnote#GetNoteBook()
let s:dConfig = vnote#GetConfig()

" OpenNoteBook: open another notebook overide the default
function! notebook#OpenNoteBook(...) "{{{
    if a:0 == 0
        echo 'current notebook: ' . s:dNoteBook.basedir
        return 0
    endif

    let l:pBasedir = expand(a:1)
    if !isdirectory(l:pBasedir)
        echoerr a:pBasedir . 'is not a valid directory?'
        return -1
    endif

    if l:pBasedir =~ '/$'
        let l:pBasedir = substitute(l:pBasedir, '/$', '', '')
    endif

    call s:jNoteBook.SetBasedir(l:pBasedir)
    :LOG 'open notebook: ' . l:pBasedir

    return 0
endfunction "}}}

" NewNote: edit new note of today
function! notebook#hNoteNew(...) "{{{
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

" EditNote: edit old note
function! notebook#hNoteEdit(...) "{{{
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
