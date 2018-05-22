" File: notebar
" Author: lymslive
" Description: ftpluign for notebar
" Create: 2018-05-22
" Modify: 2018-05-22

nnoremap <buffer> <CR> :call notebar#hEnterBar()<CR>
nnoremap <buffer> s    :call notebar#hSortTag()<CR>

" Simple Syntax:
" a section begin with -/+
syntax match Include /^[-+] \S\+/
