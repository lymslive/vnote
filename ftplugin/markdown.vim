" note filetype(base on markdown) tools
" Author: lymslive
" Date: 2017/01/23

" ref to notebook struct
let b:notebook = {}
let b:argv = []

" edit the next/prev number note of the same day
nmap <buffer> g<C-a> <Plug>(VNOTE_edit_next_note)
nmap <buffer> g<C-x> <Plug>(VNOTE_edit_prev_note)

" when cursor on a tag, open NoteList by that tag
" otherwise NoteList by the date of this note
nmap <buffer> <C-]> <Plug>(VNOTE_edit_open_list)

" same as :NoteSave
" save note and tag files if cursor on tag line
nmap <buffer> ;w <Plug>(VNOTE_edit_smart_save)

call note#Load()
