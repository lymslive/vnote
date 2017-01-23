" note tools -- edit markdown note file
" Author: lymslive
" Date: 2017/01/23

let s:filename_pattern = '^\(\d\{8}\)_\(\d\+\)\(.*\)'

" map define
nnoremap <Plug>(VNOTE_edit_next_note) :call <SID>EditNext(1)<CR>
nnoremap <Plug>(VNOTE_edit_prev_note) :call <SID>EditNext(-1)<CR>

" s:EditNext: 
function! s:EditNext(shift) "{{{
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

" Load: 
function! note#Load() "{{{
    return 1
endfunction "}}}
