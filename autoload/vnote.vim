" vnote tools
" Author: lymslive
" Date: 2017-01-22

let s:default_notebook = "~/notebook"
if exists('g:vnote_default_notebook')
    let s:default_notebook = g:vnote_default_notebook
endif

" need expand to handle ~(home)
let s:current_notebook = expand(s:default_notebook)
let s:note_file_dir = s:current_notebook . '/d'
let s:note_tags_dir = s:current_notebook . '/t'
let s:note_cache_dir = s:current_notebook . '/c'

" NewNote: edit new note of today
function! vnote#NewNote() "{{{
    let l:day_path = strftime("%Y/%m/%d")
    let l:day_int  = strftime("%Y%m%d")

    let l:day_path_full = s:note_file_dir . '/' . l:day_path
    let l:note_pattern = l:day_path_full . '/' . l:day_int . '_*.md'
    let l:list_note_file = glob(l:note_pattern, 0, 1)
    let l:count_old_note = len(l:list_note_file)
    let l:new_number = l:count_old_note + 1
    let l:new_note_file_path = l:day_path_full . '/' . l:day_int . '_' . l:new_number . '.md'

    if !isdirectory(l:day_path_full)
        call mkdir(l:day_path_full, 'p')
    endif
    " echo l:new_note_file_path
    execute 'edit ' . l:new_note_file_path
endfunction "}}}

" ListNote: list note of a day (default today)
" a:1, date argument as yyyy/mm/dd
function! vnote#ListNote(...) "{{{
    if a:0 < 1
        let l:day_path = strftime("%Y/%m/%d")
    else
        let l:day_path = a:1
    endif

    let l:day_path_full = s:note_file_dir . '/' . l:day_path
    let l:note_pattern = l:day_path_full . '/' . '*_*.md'
    let l:list_note_file = glob(l:note_pattern, 0, 1)

    let l:output_list = []
    for l:note_file in l:list_note_file
        let l:file_lines = readfile(l:note_file, '', 1)
        let l:first_line = l:file_lines[0]

        let l:file_name = strpart(l:note_file, len(l:day_path_full)+1)
        let l:note_title = substitute(l:first_line, '^\s*#\s*', '', '')
        call add(l:output_list, l:file_name . "\t" . l:note_title)
    endfor

    edit _NoteList_Buff
    set buftype=nofile
    call setline(1, '$ note-book ' . s:current_notebook)
    call setline(2, '$ note-list -d ' . l:day_path)
    call setline(3, repeat('=', 78))
    call append(line('$'), l:output_list)
    set filetype=notelist
    let b:notebook = s:current_notebook
endfunction "}}}

" ReadTags: return a list of tags of one note
" a:1 full path of note file
" return list, one item each tag line, may including multy ``
function! vnote#ReadTags(file) "{{{
    let l:note_file = a:file
    if !filereadable(l:note_file)
        return []
    endif

    let l:tags = []
    let l:file_lines = readfile(l:note_file, '', 10)
    for l:line in l:file_lines
        if l:line[0] == '`'
            call add(l:tags, l:line)
        endif
    endfor

    return l:tags
endfunction "}}}
