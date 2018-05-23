" File: notebar
" Author: lymslive
" Description: ftpluign for notebar
" Create: 2018-05-22
" Modify: 2018-05-22

nnoremap <buffer> <CR> :call notebar#hEnterBar()<CR>
nnoremap <buffer> s    :call notebar#hSortTag()<CR>

" move cursor in preview mode
nnoremap <buffer> J    :call notebar#hPreviewDown()<CR>
nnoremap <buffer> K    :call notebar#hPreviewUp()<CR>

" Simple Syntax:
" a section begin with -/+
syntax match Include /^[-+] \S\+/
syntax match Comment /<!--.*-->/
