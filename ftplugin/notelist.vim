" notelist filetype tools
" Author: lymslive
" Date: 2017-01-22

" notelist header line relate var
let b:notebook = {}
let b:argv = []

nmap <buffer> <CR> <Plug>(VNOTE_list_edit_note)
nmap <buffer> <Space> <Plug>(VNOTE_list_toggle_tagline)

nmap <buffer> <C-a> <Plug>(VNOTE_list_next_day)
nmap <buffer> <C-x> <Plug>(VNOTE_list_prev_day)

nmap <buffer> <Right> <Plug>(VNOTE_list_next_day)
nmap <buffer> <Left> <Plug>(VNOTE_list_prev_day)

call notelist#Load()
