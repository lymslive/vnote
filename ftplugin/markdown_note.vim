" note filetype(base on markdown) tools
" Author: lymslive
" Date: 2017-02-24

:PLUGINLOCAL

" edit the next/prev number note of the same day
nmap <buffer> g<C-a> <Plug>(VNOTE_edit_next_note)
nmap <buffer> g<C-x> <Plug>(VNOTE_edit_prev_note)

" when cursor on a tag, open NoteList by that tag
" otherwise NoteList by the date of this note
nmap <buffer> <C-]> <Plug>(VNOTE_edit_open_list)

nmap <buffer> <Tab> <Plug>(VNOTE_edit_smart_tab)

command! -buffer -nargs=* -complete=customlist,vnote#complete#NoteTag
        \ NoteTag call note#hNoteTag(<f-args>)

" AutoSave:
augroup VNOTE_EDIT
    autocmd! * <buffer>
    autocmd BufWritePost <buffer> call note#OnSaveNote()
augroup end

:PLUGINAFTER
