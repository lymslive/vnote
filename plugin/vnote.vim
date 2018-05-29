" vnote plugin
" Author: lymslive
" Date: 2017-02-24

if exists(':PLUGINLOCAL')
    :PLUGINLOCAL
endif

" Vnote: [-t|-w] [basedir]
" open vnote layout, default in new tabpage(-t), or current one(-w)
" if 2nd argument provided, same as :NoteBook to set it's basedir
command! -nargs=? -complete=dir 
            \ Vnote call notebook#OpenNoteTab(<f-args>)

" NoteBook:
" no argument, show the current notebook
" with one argument, switch to set that directory as current notebook
command! -nargs=? -complete=dir 
        \ NoteBook call notebook#OpenNoteBook(<f-args>)

" NoteNew:
" edit a new note with today path, add on note number, that is:
" year/month/today/yyyymmdd_<n+1>.md
command! -nargs=* -complete=customlist,vnote#complete#NoteTag
        \ NoteNew call notebook#hNoteNew(<f-args>)

" NoteEdit:
" edit mru :NoteList -1
" edit last note in a day: NoteEdit day_path(yyyy/mm/dd)
command! -nargs=*  -complete=customlist,vnote#complete#NoteDate
        \ NoteEdit call notebook#hNoteEdit(<f-args>)

" NoteList:
" list note support tow or four mode:
" :NoteList day_path, default today, list all note of this day
" :NoteList tag, list all note that has this tag
" :NoteList -D [partial day_path], browse date that have note
" :NOteList -T [partial tag], browse all tags
command! -nargs=* -complete=customlist,vnote#complete#NoteList
        \ NoteList call notelist#hNoteList(<f-args>)

" see and set config
command! -nargs=* -complete=customlist,vnote#complete#NoteConfig
        \ NoteConfig call vnote#hNoteConfig(<f-args>)

" build cache index for notebook
" -t option also rebuild all tagfiles
" -u option update to today, only supported by perlx
command! -nargs=* NoteIndex call notebook#hNoteIndex(<f-args>)

" copy import a file into notebook
command! -nargs=* NoteImport call notebook#hNoteImport(<f-args>)

augroup VNOTE
    autocmd!
    autocmd VimLeavePre * call vnote#OnVimLeave()
    autocmd BufReadPost *.md,*.MD call note#OnBufRead()
augroup END

if exists(':PLUGINAFTER')
    :PLUGINAFTER
endif
