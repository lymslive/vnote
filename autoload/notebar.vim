" File: notebar
" Author: lymslive
" Description: notebar tools
" Create: 2018-05-22
" Modify: 2018-05-22

" CheckBuffer: return true if valid notebar buffer
function! s:CheckBuffer() abort "{{{
    return &filetype ==# 'notebar' && exists('b:jNoteBar')
endfunction "}}}

" EnterBar: <CR> in notebar window
" open notelist with argument from under cursor
function! notebar#hEnterBar() abort "{{{
    if !s:CheckBuffer()
        return -1
    endif

    let l:sArg = b:jNoteBar.GetCursorArg()
    if type(l:sArg) == type([])
        let l:iWinnr = vnote#GotoListWindow()
        if l:iWinnr == 0
            if winnr('$') > 1
                :wincmd w
            else
                :belowright vsplit
            endif
        endif
        call call('notelist#hNoteList', l:sArg)
    endif
endfunction "}}}

" PreviewDown: 
function! notebar#hPreviewDown() abort "{{{
    :normal! j
    call notebar#hEnterBar()
    call vnote#GotoBarWindow()
endfunction "}}}

" PreviewUp:
function! notebar#hPreviewUp() abort "{{{
    :normal! k
    call notebar#hEnterBar()
    call vnote#GotoBarWindow()
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

" ShowHelpKey: 
function! notebar#hShowHelpKey() abort "{{{
    if !s:CheckBuffer()
        return -1
    endif
    let l:iWinnr = vnote#GotoListWindow()
    if l:iWinnr == 0
        if winnr('$') > 1
            :wincmd w
        else
            :belowright vsplit
        endif
        call notelist#hNoteList('-m')
    endif
    if &filetype ==? 'notelist'
        call notelist#hShowHelpKey()
    endif
endfunction "}}}

" PasteTag: yank and/or paste tag name to editing note
" list notelist#hPasteTag()
function! notebar#hPasteTag(yes) abort "{{{
    if !s:CheckBuffer()
        return -1
    endif
    let l:iTagSection = search('^[-+] tag', 'bn')
    if l:iTagSection < line('.')
        let l:sTag = matchstr(getline('.'), '^\s\+\zs\S\+\ze')
        return notelist#PasteTag(l:sTag, a:yes)
    endif
endfunction "}}}

" NewNote: create new note with tag under cursor
" a:1 says create private diary
function! notebar#hNewNote(...) abort "{{{
    if !s:CheckBuffer()
        return -1
    endif

    let l:iTagSection = search('^[-+] tag', 'bn')
    if l:iTagSection < line('.')
        let l:sTag = matchstr(getline('.'), '^\s\+\zs\S\+\ze')
        if empty(l:sTag)
            return -1
        endif
        let l:bPrivate = get(a:000, 0, 0)
        if l:bPrivate || !empty(l:bPrivate)
            call notebook#hNoteNew('-', '-t',  l:sTag)
        else
            call notebook#hNoteNew('-t',  l:sTag)
        endif
    endif
endfunction "}}}

" JumpSection: 
function! notebar#hJumpSection(flag) abort "{{{
    if !s:CheckBuffer()
        return -1
    endif
    call search('^[-+]\s', a:flag)
endfunction "}}}

" STL: local statusline
function! notebar#STL() abort "{{{
    let l:version = printf('%.2f', g:vnote#version)
    let l:stl = 'vnote ' . l:version . '%=bar'
    return l:stl
endfunction "}}}
