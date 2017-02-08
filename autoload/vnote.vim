" vnote tools
" Author: lymslive
" Date: 2017/01/23

let s:default_notebook = "~/notebook"
if exists('g:vnote_default_notebook')
    let s:default_notebook = g:vnote_default_notebook
endif

let s:note_suffix = '.md'
" regexp: yyyy/mm/dd
let s:day_path_pattern = '\d\d\d\d/\d\d/\d\d'

" need expand to handle ~(home)
let s:current_notebook = expand(s:default_notebook)

" build a dict serve as a data struct for global use
let s:dNoteBook = {}
let s:dNoteBook.basedir = s:current_notebook
let s:dNoteBook.suffix = s:note_suffix

" NoteBook Methods: 
function! s:dNoteBook.Filedir() dict "{{{
    return self.basedir . '/d'
endfunction "}}}
function! s:dNoteBook.Tagdir() dict "{{{
    return self.basedir . '/t'
endfunction "}}}
function! s:dNoteBook.Cachedir() dict "{{{
    return self.basedir . '/c'
endfunction "}}}

" Notedir: full path of a day
function! s:dNoteBook.Notedir(day_path) dict "{{{
    if match(a:day_path, s:day_path_pattern) == -1
        echoerr a:day_path . ' is not a valid day path as yyyy/mm/dd'
        return ''
    else
        return self.Filedir() . '/' . a:day_path
    endif
endfunction "}}}

" Notefile: full path of a note, given date and number
" return notebook/d/yyyy/mm/dd/yyyymmdd_n.md
function! s:dNoteBook.Notefile(day_path, seqno) dict "{{{
    if match(a:day_path, s:day_path_pattern) == -1
        echoerr a:day_path . ' is not a valid day path as yyyy/mm/dd'
        return ''
    endif

    let l:day_int = substitute(a:day_path, '/', '', 'g')
    return s:dNoteBook.Filedir() . '/' . a:day_path . '/' . l:day_int . '_' . a:seqno . s:dNoteBook.suffix
endfunction "}}}

" GetNoteBook: 
function! vnote#GetNoteBook() "{{{
    return s:dNoteBook
endfunction "}}}

" OpenNoteBook: open another notebook overide the default
function! vnote#OpenNoteBook(...) "{{{
    if a:0 == 0
        echo 'current notebook: ' . s:dNoteBook.basedir
        return 0
    endif

    let l:basedir = expand(a:1)
    if !isdirectory(l:basedir)
        echoerr a:basedir . 'is not a valid directory?'
        return 0
    endif

    if match(l:basedir, '/$') != -1
        let l:basedir = substitute(l:basedir, '/$', '', '')
    endif

    let s:dNoteBook.basedir = l:basedir
    echo 'open notebook: ' . l:basedir
    return 1
endfunction "}}}

" NewNote: edit new note of today
function! vnote#NewNote() "{{{
    let l:day_path = s:TodayPath()
    let l:day_int  = s:TodayInt()

    let l:day_path_full = s:dNoteBook.Notedir(l:day_path)
    if empty(l:day_path_full)
        return 0
    endif

    let l:count_old_note = s:NoteCountByDay(l:day_path)
    let l:new_number = l:count_old_note + 1
    let l:new_note_file_path = s:dNoteBook.Notefile(l:day_path, l:new_number)

    if !isdirectory(l:day_path_full)
        call mkdir(l:day_path_full, 'p')
    endif
    " echo l:new_note_file_path
    execute 'edit ' . l:new_note_file_path
endfunction "}}}

" EditNote: 
function! vnote#EditNote(...) "{{{
    if a:0 >= 1
        let l:day_path = a:1
    else
        let l:day_path = s:TodayPath()
    endif

    if a:0 >= 2
        let l:seqno = a:2
    else
        let l:seqno = s:NoteCountByDay(l:day_path)
    endif

    let l:day_path_full = s:dNoteBook.Notedir(l:day_path)
    if empty(l:day_path_full)
        return 0
    endif

    if l:seqno <= 0 && !isdirectory(l:day_path_full)
        call mkdir(l:day_path_full, 'p')
        let l:seqno = 1
    endif
    
    let l:note_file_path = s:dNoteBook.Notefile(l:day_path, l:seqno)
    execute 'edit ' . l:note_file_path
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

" s:NoteCountByDay: 
function! s:NoteCountByDay(day_path) "{{{
    let l:day_path = a:day_path
    let l:day_path_full = s:dNoteBook.Notedir(l:day_path)
    if empty(l:day_path_full)
        return 0
    endif

    let l:day_int = substitute(l:day_path, '/', '', 'g')
    let l:note_pattern = l:day_path_full . '/' . l:day_int . '_*' . s:note_suffix
    let l:list_note_file = glob(l:note_pattern, 0, 1)
    let l:count = len(l:list_note_file)

    return l:count
endfunction "}}}
