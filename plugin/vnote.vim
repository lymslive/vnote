" vnote plugin
" Author: lymslive
" Date: 2017-01-22

command! -nargs=0 NoteNew call vnote#NewNote()
command! -nargs=* NoteList call vnote#ListNote(<f-args>)
