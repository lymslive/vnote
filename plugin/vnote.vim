" vnote plugin
" Author: lymslive
" Date: 2017-01-22

command! -nargs=1 -complete=file NoteBook call vnote#OpenNoteBook(<f-args>)
command! -nargs=0 NoteNew call vnote#NewNote()
command! -nargs=* NoteEdit call vnote#EditNote(<f-args>)
command! -nargs=* -complete=customlist,notelist#CompleteList NoteList call notelist#ListNote(<f-args>)
