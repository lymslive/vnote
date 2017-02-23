" notelist filetype tools
" Author: lymslive
" Date: 2017-01-22

" notelist header line relate var
let b:notebook = {}
let b:argv = []

" enter to edit the note under the cursor
" if have more than one window, open the note in another window
" if NoteList -D or -T mode, enter to list the subpath
nmap <buffer> <CR> <Plug>(VNOTE_list_edit_note)

" edit note in a vsplit new window if none
nmap <buffer> <Tab> <Plug>(VNOTE_list_smart_tab)

" back to list an upper level
nmap <buffer> <BS> <Plug>(VNOTE_list_back_list)
nmap <buffer> a <Plug>(VNOTE_list_back_list)
nmap <buffer> i <Plug>(VNOTE_list_edit_note)

" NoteList default list each note entry containing
" file name without extention and note title(first line)
" this map open a line to show tags of the note under cursor
nmap <buffer> <Space> <Plug>(VNOTE_list_toggle_tagline)

" these map only used when NoteList by date
nmap <buffer> <C-a> <Plug>(VNOTE_list_next_day)
nmap <buffer> <C-x> <Plug>(VNOTE_list_prev_day)
nmap <buffer> <Right> <Plug>(VNOTE_list_next_day)
nmap <buffer> <Left> <Plug>(VNOTE_list_prev_day)
nmap <buffer> <Down> <Plug>(VNOTE_list_next_month)
nmap <buffer> <Up> <Plug>(VNOTE_list_prev_month)

" switch NoteList with -D or -T argument
nmap <buffer> T <Plug>(VNOTE_list_browse_tag)
nmap <buffer> D <Plug>(VNOTE_list_browse_date)

" if cursor on date, NoteList by that data
" if cursor on a tag(when open tag line), NoteList by that tag
nmap <buffer> t <Plug>(VNOTE_list_smart_jump)

call notelist#Load()
