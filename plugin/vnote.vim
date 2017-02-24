" vnote plugin
" Author: lymslive
" Date: 2017-02-24

" NoteBook:
" no argument, show the current notebook
" with one argument, switch to set that directory as current notebook
command! -nargs=? -complete=file 
        \ NoteBook call notebook#OpenNoteBook(<f-args>)

" NoteNew:
" edit a new note with today path, add on note number, that is:
" year/month/today/yyyymmdd_<n+1>.md
command! -nargs=? NoteNew call notebook#hNoteNew(<f-args>)

" NoteEdit:
" accept at most two arguments: NoteEdit day_path(yyyy/mm/dd) number
" day_path default to today path
" number default to the last note number of that day
command! -nargs=* NoteEdit call notebook#hNoteEdit(<f-args>)

" NoteList:
" list note support tow or four mode:
" :NoteList day_path, default today, list all note of this day
" :NoteList tag, list all note that has this tag
" :NoteList -D [partial day_path], browse date that have note
" :NOteList -T [partial tag], browse all tags
command! -nargs=* -complete=customlist,vnote#complete#NoteList
        \ NoteList call notelist#hNoteList(<f-args>)

command! -nargs=* -complete=customlist,vnote#complete#NoteConfig
        \ NoteConfig call vnote#hNoteConfig(<f-args>)
