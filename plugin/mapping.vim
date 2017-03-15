" File: mapping
" Author: lymslive
" Description: plugin mappings
" Create: 2017-02-24
" Modify: 2017-03-15

" to use thes mappings, use nmap not nnoremap
nnoremap <Plug>(VNOTE_book_new_note) :call notebook#hNoteNew()
nnoremap <Plug>(VNOTE_book_new_private_note) :call notebook#hNoteNew('-')
nnoremap <Plug>(VNOTE_book_edit_last_note) :call notebook#hNoteEdit()

" recommend local in notelist buffer
nnoremap <Plug>(VNOTE_list_edit_note) :call notelist#hEnterNote()<CR>
nnoremap <Plug>(VNOTE_list_toggle_tagline) :call notelist#ToggleTagLine()<CR>
nnoremap <Plug>(VNOTE_list_next_day) :call notelist#NextDay(1)<CR>
nnoremap <Plug>(VNOTE_list_prev_day) :call notelist#NextDay(-1)<CR>
nnoremap <Plug>(VNOTE_list_next_month) :call notelist#NextMonth(1)<CR>
nnoremap <Plug>(VNOTE_list_prev_month) :call notelist#NextMonth(-1)<CR>
nnoremap <Plug>(VNOTE_list_smart_jump) :call notelist#hSmartJump()<CR>
nnoremap <Plug>(VNOTE_list_smart_tab) :call notelist#hSmartTab()<CR>
nnoremap <Plug>(VNOTE_list_back_list) :call notelist#hBackList()<CR>
nnoremap <Plug>(VNOTE_list_browse_tag) :call notelist#hNoteList('-T')<CR>
nnoremap <Plug>(VNOTE_list_browse_date) :call notelist#hNoteList('-D')<CR>
nnoremap <Plug>(VNOTE_list_browse_mark) :call notelist#hNoteList('-M')<CR>
nnoremap <Plug>(VNOTE_list_pick_tag) :call notelist#hPasteTag()<CR>
nnoremap <Plug>(VNOTE_list_switch_unite) :Unite notelist<CR>
nnoremap <Plug>(VNOTE_list_delete_entry) :call notelist#hDelete()<CR>
nnoremap <Plug>(VNOTE_list_rename_entry) :call notelist#hRename()<CR>

" recommend local in note buffer (markdown)
nnoremap <Plug>(VNOTE_edit_next_note) :call note#EditNext(1)<CR>
nnoremap <Plug>(VNOTE_edit_prev_note) :call note#EditNext(-1)<CR>
nnoremap <Plug>(VNOTE_edit_open_list) :call note#OpenNoteList()<CR>
nnoremap <Plug>(VNOTE_edit_smart_tab) :call note#hSmartTab()<CR>

