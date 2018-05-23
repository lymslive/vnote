" notelist filetype tools
" Author: lymslive
" Date: 2017-02-24

:PLUGINLOCAL

" enter to edit the note under the cursor
" if have more than one window, open the note in another window
" if NoteList -D or -T mode, enter to list the subpath
nmap <buffer> <CR> <Plug>(VNOTE_list_edit_note)
nmap <buffer> i <Plug>(VNOTE_list_edit_note)

" edit note in a vsplit new window if none
nmap <buffer> <Tab> <Plug>(VNOTE_list_smart_tab)

" back to list an upper level
nmap <buffer> <BS> <Plug>(VNOTE_list_back_list)
nmap <buffer> a <Plug>(VNOTE_list_back_list)

" NoteList default list each note entry containing
" file name without extention and note title(first line)
" this map open a line to show tags of the note under cursor
" when browse tag mode, directlly edit the tag file
nmap <buffer> <Space> <Plug>(VNOTE_list_smart_space)
nmap <buffer> o <Plug>(VNOTE_list_smart_space)

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
nmap <buffer> M <Plug>(VNOTE_list_browse_mark)

" if cursor on date, NoteList by that data
" if cursor on a tag(when open tag line), NoteList by that tag
nmap <buffer> t <Plug>(VNOTE_list_smart_jump)

nmap <buffer> p <Plug>(VNOTE_list_pick_tag)

" switch to unite
nmap <buffer> u <Plug>(VNOTE_list_switch_unite)

nmap <buffer> gg <Plug>(VNOTE_list_goto_first)

" goto the command line and copy the argments
nnoremap <buffer> <expr> C notelist#hRefineArg()

" manage tags over notebook: delete, rename, merge
" :NoteTag {-d|r|m} {args}
command! -buffer -nargs=* -complete=customlist,vnote#complete#NoteTag
            \ NoteTag call notelist#hManageTag(<f-args>)

" copy the context under cursor to cmdline
cnoremap <buffer> <C-x>t <C-R>=note#GetContext()<CR>

" work on NoteList -T mode, feed current tag to :NoteTag
" waiting <CR> confirm to execute
" nnoremap <buffer> dd :NoteTag -d <C-R>=note#GetContext()<CR>
nnoremap <buffer> R  :NoteTag -r <C-R>=note#GetContext()<CR>
" common delete map
nmap <buffer> dd <Plug>(VNOTE_list_delete_this)

" work on NoteList -t|-T mode
nmap <buffer> n <Plug>(VNOTE_list_new_note_with_tag)
nmap <buffer> N <Plug>(VNOTE_list_new_dairy_with_tag)

" move cursor in preview mode
nnoremap <buffer> J    :call notelist#hPreviewDown()<CR>
nnoremap <buffer> K    :call notelist#hPreviewUp()<CR>

" Simple Syntax:
" noteid yyyymmdd_n
syntax match Number /^\d\+_\d\+/
" note title
syntax match String /\t[^\t]\+/
" note tags [tag|tag]
syntax match Tag /\t\[.*\]/
syntax match Comment /<!--.*-->/

:PLUGINAFTER
