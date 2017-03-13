" File: makeindex
" Author: lymslive
" Description: test the :NoteIndex performance
" Create: 2017-03-13
" Modify: 2017-03-13

" ./genbox.pl ~/test/notebook
NoteBook ~/test/notebook
let g:tic = reltime()
NoteIndex -t
let g:toc = reltimestr(reltime(g:tic))
echo g:toc
" in my computer, it output:
" 35.247608
