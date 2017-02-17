" vnote plugin
" Author: lymslive
" Date: 2017-01-22

" NoteBook:
" no argument, show the current notebook
" with one argument, switch to set that directory as current notebook
command! -nargs=? -complete=file NoteBook call vnote#OpenNoteBook(<f-args>)

" NoteNew:
" edit a new note with today path, add on note number, that is:
" year/month/today/yyyymmdd_<n+1>.md
command! -nargs=0 NoteNew call vnote#hNewNote()

" NoteEdit:
" accept at most two arguments: NoteEdit day_path(yyyy/mm/dd) number
" day_path default to today path
" number default to the last note number of that day
command! -nargs=* NoteEdit call vnote#hEditNote(<f-args>)

" NoteList:
" list note support tow or four mode:
" :NoteList day_path, default today, list all note of this day
" :NoteList tag, list all note that has this tag
" :NoteList -D [partial day_path], browse date that have note
" :NOteList -T [partial tag], browse all tags
command! -nargs=* -complete=customlist,notelist#CompleteList NoteList call notelist#hListNote(<f-args>)
