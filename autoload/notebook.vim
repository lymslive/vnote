" File: notebook
" Author: lymslive
" Description: manage notebook
" Create: 2017-02-24
" Modify: 2018-04-19

" import s:jNoteBook from vnote
let s:jNoteBook = vnote#GetNoteBook()
let s:dConfig = vnote#GetConfig()

" OpenNoteBook: open another notebook overide the default
function! notebook#OpenNoteBook(...) "{{{
    if a:0 == 0
        echo 'current notebook: ' . s:jNoteBook.basedir
        return 0
    endif

    let l:pBasedir = expand(a:1)
    if !isdirectory(l:pBasedir)
        echoerr a:pBasedir . 'is not a valid directory?'
        return -1
    endif

    if l:pBasedir =~ '/$'
        let l:pBasedir = substitute(l:pBasedir, '/$', '', '')
    endif

    call s:jNoteBook.SetBasedir(l:pBasedir)
    :LOG 'open notebook: ' . l:pBasedir

    return 0
endfunction "}}}

" NewNote: edit new note of today
function! notebook#hNoteNew(...) "{{{
    let l:sDatePath = strftime("%Y/%m/%d")
    let l:bPrivate = g:class#FALSE
    let l:lsTag = []
    let l:lsTitle = []

    if a:0 == 1 && a:1 ==# '-'
        let l:bPrivate = g:class#TRUE
    else
        " complex argument parse
        let l:jOption = class#viml#cmdline#new('NoteNew')
        call l:jOption.AddMore('t', 'tag', 'tags of new note', [])
        call l:jOption.AddMore('T', 'title', 'the title of new note', [])
        call l:jOption.AddDash('create private dairy')

        let l:iErr = l:jOption.ParseCheck(a:000)
        if l:iErr != 0
            return l:iErr
        endif

        let l:bPrivate = l:jOption.HasDash()
        let l:lsTag = l:jOption.Get('tag')
        let l:lsTitle = l:jOption.Get('title')

        let l:lsPost = l:jOption.GetPost()
        if !empty(l:lsPost)
            if empty(l:lsTag)
                let l:lsTag = l:lsPost
            elseif empty(l:lsTitle)
                let l:lsTitle = l:lsPost
            else
                :WLOG 'ignor position arguments'
            endif
        endif
    endif

    let l:pNoteFile = s:jNoteBook.AllocNewNote(l:sDatePath, l:bPrivate)
    let l:pDirectory = s:jNoteBook.Notedir(l:sDatePath)
    if !isdirectory(l:pDirectory)
        call mkdir(l:pDirectory, 'p')
    endif

    call vnote#GotoNoteWindow()
    execute 'edit ' . l:pNoteFile

    " generate title
    if empty(l:lsTitle)
        call append(0, '# note title')
    else
        call append(0, '# ' . join(l:lsTitle, ' '))
    endif

    " generate tags
    let l:sTagLine = ''
    if l:bPrivate
        if s:dConfig.auto_add_minus_tag
            let l:sTagLine .= '`-`'
        endif
    else
        if s:dConfig.auto_add_plus_tag
            let l:sTagLine .= '`+`'
        endif
    endif

    if !empty(l:lsTag)
        call map(l:lsTag, 'printf("`%s`", v:val)')
        let l:sTagLine .= ' ' . join(l:lsTag, ' ')
    endif

    if !empty(l:sTagLine)
        call append(1, l:sTagLine)
    endif

    " put cursor on title
    normal ggw
endfunction "}}}

" EditNote: edit old note
function! notebook#hNoteEdit(...) "{{{
    if a:0 >= 1
        let l:sArg = a:1
    else
        " let l:sDatePath = strftime("%Y/%m/%d")
        let l:sArg = -1
    endif

    let l:pNoteFile = ''

    " simple number, treat as mru index
    if l:sArg =~# '^-\?\d\+$' && len(l:sArg) < 4
        let l:lsMru = s:jNoteBook.GetMruList()
        let l:sNoteEntry = get(l:lsMru, 0+l:sArg, '')
        let l:jNoteEntry = class#notename#new(l:sNoteEntry)
        let l:pNoteFile = l:jNoteEntry.GetFullPath(s:jNoteBook)
    else
        let l:sDatePath = l:sArg
        let l:pDirectory = s:jNoteBook.Notedir(l:sDatePath)
        if !empty(l:pDirectory)
            let l:pNoteFile = s:jNoteBook.GetLastNote(l:sDatePath)
        endif
    endif

    if !empty(l:pNoteFile)
        call vnote#GotoNoteWindow()
        execute 'edit ' . l:pNoteFile
    else
        :WLOG 'note non-existed'
    endif
endfunction "}}}

" NoteIndex: build cache index for notebook
function! notebook#hNoteIndex(...) abort "{{{
    let l:iErr = s:jNoteBook.RebuildCache(a:000)
    :LOG 'NoteIndex done: E' . l:iErr
    return l:iErr
endfunction "}}}

" NoteImport: import current buffer file into notebook
" [-p] copy import, also default when no arg
" [-s] soft link, yyyymmdd_n.md is a link to {%:p}
" [-S] soft note, title as # !/full/path/to/current/file
" auto add bookmark in: copyin linkin softin
function! notebook#hNoteImport(...) abort "{{{
    if note#IsInBook()
        :ELOG 'this file is already in current notebook'
        return 0
    endif

    let l:extention = expand('%:p:t:e')
    if l:extention !~? 'md\|txt'
        let l:reply = input("the file seems not text file, really import as a note?\n[yes|no] ", 'n')
        if l:reply !~? '^y'
            return 0
        endif
    endif

    let l:sDatePath = strftime("%Y/%m/%d")
    let l:pNoteFile = s:jNoteBook.AllocNewNote(l:sDatePath, g:class#FALSE)
    let l:pDirectory = s:jNoteBook.Notedir(l:sDatePath)
    if !isdirectory(l:pDirectory)
        call mkdir(l:pDirectory, 'p')
    endif

    update
    if a:0 == 0 || empty(a:1) || a:1 =~# '^-\?p'
        execute 'saveas ' . l:pNoteFile
        call note#hNoteMark('copyin')
    elseif a:1 =~# '^-\?P'
        try
            call system('mv ' . expand('%:p') . ' ' . l:pNoteFile)
            execute 'edit ' . l:pNoteFile
            call note#hNoteMark('copyin')
        catch 
            :ELOG 'fail to move file to note, use copy import: -p'
        endtry
    elseif a:1 =~# '^-\?s'
        if executable('ln')
            try
                call system('ln -s ' . expand('%:p') . ' ' . l:pNoteFile)
                let l:sName = fnamemodify(l:pNoteFile, ':t:r')
                let l:sTitle = substitute(getline(1), '^\s*#\s*', '', '')
                let l:jNoteTag = class#notetag#mark#new('linkin')
                call l:jNoteTag.UpdateEntry(l:sName . "\t" . l:sTitle, 1)
            catch 
                :ELOG 'fail to make soft link, use copy import: -p'
            endtry
        else
            :ELOG 'can not make soft link, use copy import: -p'
        endif
    elseif a:1 =~# '^-\?S'
        let l:sTitle = expand('%:p')
        call notebook#hNoteNew('-T', '!' . l:sTitle)
        call note#hNoteMark('softin')
    endif
endfunction "}}}
