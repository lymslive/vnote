" File: notebar
" Author: lymslive
" Description: notebar tools
" Create: 2018-05-22
" Modify: 2018-05-22

" EnterBar: <CR> in notebar window
" open notelist with argument from under cursor
function! notebar#hEnterBar() abort "{{{
    if !s:CheckBuffer()
        return -1
    endif

    let l:sArg = b:jNoteBar.GetCursorArg()
    if type(l:sArg) == type([])
        call call('notelist#hNoteList', l:sArg)
    endif
endfunction "}}}

" SortTag: switch sort type of tag section
function! notebar#hSortTag() abort "{{{
    if !s:CheckBuffer()
        return -1
    endif
    call b:jNoteBar.SortTag()
endfunction "}}}

" RreshTree: refresh a sub section tree under cursor
function! notebar#hRreshTree() abort "{{{
    " code
endfunction "}}}

" CheckBuffer: return true if valid notebar buffer
function! s:CheckBuffer() abort "{{{
    return &filetype ==# 'notebar' && exists('b:jNoteBar')
endfunction "}}}
