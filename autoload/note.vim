" note tools -- edit markdown note file
" Author: lymslive
" Date: 2017/01/23

let s:filename_pattern = '^\(\d\{8}\)_\(\d\+\)\(.*\)'

" map define
nnoremap <Plug>(VNOTE_edit_next_note) :call <SID>EditNext(1)<CR>
nnoremap <Plug>(VNOTE_edit_prev_note) :call <SID>EditNext(-1)<CR>
nnoremap <Plug>(VNOTE_edit_open_list) :call <SID>OpenNoteList()<CR>

" EditNext: edit next note of the same day
function! s:EditNext(shift) "{{{
    if !s:NoteInBook()
        return 0
    endif

    let l:note_file = expand('%:t')
    let l:note_dir = expand('%:p:h')

    let l:file_name_parts = matchlist(l:note_file, s:filename_pattern)
    if empty(l:file_name_parts)
        echoerr l:note_file . ' may be not note file'
        return 0
    endif

    let l:file_name_parts[2] = l:file_name_parts[2] + a:shift
    let l:file_name_new = l:file_name_parts[1] . '_' . l:file_name_parts[2] . l:file_name_parts[3]

    execute 'edit ' l:note_dir . '/' . l:file_name_new
endfunction "}}}

" OpenNoteList: call ListNote with tag under cursor or current day
function! s:OpenNoteList() abort "{{{
    if !s:NoteInBook()
        echo 'not in notebook?'
        return 0
    endif

    let l:tag = note#DetectTag(1)
    if empty(l:tag)
        let l:day_path = s:GetDayPath()
        call notelist#ListNote(l:day_path)
    else
        call notelist#ListNote(l:tag)
    endif

endfunction "}}}

" NoteInBook: true if current buffer is in current notebook
function! s:NoteInBook() abort "{{{
    let l:dNoteBook = vnote#GetNoteBook()
    let l:note_dir = l:dNoteBook.Filedir()
    let l:file_dir = expand('%:p')
    if match(l:file_dir, '^' . l:note_dir) != -1
        return 1
    else
        return 0
    endif
endfunction "}}}

" GetDayPath: get yyyy/mm/dd string from current file name
function! s:GetDayPath() abort "{{{
    let l:note_file = expand('%:t')
    let l:file_name_parts = matchlist(l:note_file, s:filename_pattern)
    if empty(l:file_name_parts)
        echoerr l:note_file . ' may be not note file'
        return ''
    endif

    let l:day_int = l:file_name_parts[1]
    if len(l:day_int) != 8
        echoerr l:note_file . ' may be not note file'
        return ''
    endif

    let l:day_path = strpart(l:day_int, 0, 4) . '/' . strpart(l:day_int, 4, 2) . '/' . strpart(l:day_int, 6, 2) 
    return l:day_path
endfunction "}}}

" DetectTag: get a tag under cursor, the string between two `` marks
" a:bol, begin of line, require the mark at bol or not
function! note#DetectTag(bol) abort "{{{
    let l:line = getline('.')
    if a:bol && match(l:line, '^\s*`.*`') == -1
        return ''
    endif

    let l:col_pos = col('.')
    let l:col_idx = l:col_pos - 1

    " use stack algorithm to find the `` pair around cursor
    let l:quote_stack = []
    let l:quote_left = -1
    let l:quote_right = -1
    for l:idx in range(len(l:line))
        if l:line[l:idx] != '`'
            continue
        endif

        if empty(l:quote_stack)
            if l:idx <= l:col_idx
                call add(l:quote_stack, l:idx)
            else
                " already beyond right out the cursor
                break
            endif
        else
            if l:idx >= l:col_idx
                let l:quote_left = remove(l:quote_stack, -1)
                let l:quote_right = l:idx
            else
                call remove(l:quote_stack, -1)
            endif
        endif
    endfor

    " extract the tag string in ``
    if l:quote_left == -1 || l:quote_right == -1
        return ''
    elseif l:quote_right - l:quote_left <= 1
        return ''
    else
        return strpart(l:line, l:quote_left+1, l:quote_right-l:quote_left - 1)
    endif
endfunction "}}}

" Load: 
function! note#Load() "{{{
    return 1
endfunction "}}}

" note#Test: 
function! note#Test() abort "{{{
    " echo s:GetDayPath()
    " echo s:DetectTag()
    if !s:NoteInBook()
        echo 'not in notebook?'
    else
        echo 'yes in notebook'
    endif
    return 1
endfunction "}}}
