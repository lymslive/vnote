" note filetype(base on markdown) tools
" Author: lymslive
" Date: 2017/01/23

" ref to notebook struct
let b:notebook = {}
let b:argv = []

nmap <buffer> g<C-a> <Plug>(VNOTE_edit_next_note)
nmap <buffer> g<C-x> <Plug>(VNOTE_edit_prev_note)
nmap <buffer> <C-]> <Plug>(VNOTE_edit_open_list)

call note#Load()
