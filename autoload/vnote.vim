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
function! vnote#hNewNote(...) "{{{
    let l:sDatePath = s:TodayPath()

    if a:0 > 0 && a:1 ==# '-'
        let l:pNoteFile = s:jNoteBook.AllocNewNote(l:sDatePath, v:true)
    else
        let l:pNoteFile = s:jNoteBook.AllocNewNote(l:sDatePath)
    endif

    let l:pDirectory = s:jNoteBook.Notedir(l:sDatePath)
    if !isdirectory(l:pDirectory)
        call mkdir(l:pDirectory, 'p')
    endif

    execute 'edit ' . l:pNoteFile
endfunction "}}}

" EditNote: 
function! vnote#hEditNote(...) "{{{
    if a:0 >= 1
        let l:sDatePath = a:1
    else
        let l:sDatePath = s:TodayPath()
    endif

    let l:pDirectory = s:jNoteBook.Notedir(l:sDatePath)
    if empty(l:pDirectory)
        return 0
    endif
    if !isdirectory(l:pDirectory)
        call mkdir(l:pDirectory, 'p')
    endif

    let l:pNoteFile = s:jNoteBook.GetLastNote(l:sDatePath)
    " to match private note also
    execute 'edit ' . fnamemodify(l:pNoteFile, ':r') . '*'
endfunction "}}}

" s:TodayPath: yyyy/mm/dd as a path
function! s:TodayPath() "{{{
    let l:day_path = strftime("%Y/%m/%d")
    return l:day_path
endfunction "}}}

" s:TodayInt: yyyymmdd as a integer
function! s:TodayInt() "{{{
    let l:day_int  = strftime("%Y%m%d")
    return l:day_int
endfunction "}}}

