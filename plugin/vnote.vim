" vnote plugin
" Author: lymslive
" Date: 2017-01-22

command! -nargs=0 NoteNew call vnote#NewNote()
command! -nargs=* NoteEdit call vnote#EditNote(<f-args>)
command! -nargs=* NoteList call notelist#ListNote(<f-args>)
