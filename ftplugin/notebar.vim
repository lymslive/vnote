" File: notebar
" Author: lymslive
" Description: ftpluign for notebar
" Create: 2018-05-22
" Modify: 2018-05-22

" Key Map: {{{1
nnoremap <buffer> <CR> :call notebar#hEnterBar()<CR>
nnoremap <buffer> s    :call notebar#hSortTag()<CR>

" move cursor in preview mode
nnoremap <buffer> J    :call notebar#hPreviewDown()<CR>
nnoremap <buffer> K    :call notebar#hPreviewUp()<CR>

" quick help doc
noremap <buffer> ? :call notebar#hShowHelpKey()<CR>

" paste or yank tag name
nnoremap <buffer> p :call notebar#hPasteTag(1)<CR>
nnoremap <buffer> P :call notebar#hPasteTag(0)<CR>

" create new note or dairy with select tag
nnoremap <buffer> n :call notebar#hNewNote(0)<CR>
nnoremap <buffer> N :call notebar#hNewNote(1)<CR>

" move to last/next section, prefixed by -/+
noremap <buffer> [[ :call notebar#hJumpSection('b')<CR>
noremap <buffer> ]] :call notebar#hJumpSection('')<CR>

nnoremap <buffer> o :call notebar#hOpenCloseDate()<CR>

" Simple Syntax: {{{1
" a section begin with -/+
syntax match Include /^[-+] \S\+/
syntax match Number /\[\d\+\]$/
syntax match Number /\d\+\/$/
syntax match Comment /<!--.*-->/
syntax match Tag /^  \S\+/

"Set Option: {{{1
setlocal statusline=%!notebar#STL()
