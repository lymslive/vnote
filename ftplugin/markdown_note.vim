" note filetype(base on markdown) tools
" Author: lymslive
" Modify: 2017-03-15

if !note#IsInBook()
    finish
endif

:PLUGINLOCAL

" edit the next/prev number note of the same day
nmap <buffer> g<C-a> <Plug>(VNOTE_edit_next_note)
nmap <buffer> g<C-x> <Plug>(VNOTE_edit_prev_note)

" when cursor on a tag, open NoteList by that tag
" otherwise NoteList by the date of this note
nmap <buffer> <C-]> <Plug>(VNOTE_edit_open_list)

nmap <buffer> <Tab> <Plug>(VNOTE_edit_smart_tab)

" :NoteTag tag (add tag to buffer)
" :NoteTag -d tag (delete tag)
command! -buffer -nargs=* -complete=customlist,vnote#complete#NoteTag
        \ NoteTag call note#hNoteTag(<f-args>)

" :NoteMark tag (add this note to bookmark {tag})
command! -buffer -nargs=* -complete=customlist,vnote#complete#NoteTag
        \ NoteMark call note#hNoteMark(<f-args>)

" AutoSave:
augroup VNOTE_EDIT
    autocmd! * <buffer>
    autocmd BufWritePost <buffer> call note#OnSaveNote()
augroup END

" :NoteSave 1
" with argument to force save
command! -buffer -nargs=? NoteSave call note#OnSaveNote(<f-args>)

" <C-X><C-U> complete to insert tag
setlocal completefunc=vnote#complete#InsertTag

:PLUGINAFTER
