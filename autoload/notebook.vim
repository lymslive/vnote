" File: notebook
" Author: lymslive
" Description: manage notebook
" Create: 2017-02-24
" Modify: 2017-02-24

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
    let l:bPrivate = v:false
    let l:lsTag = []
    let l:lsTitle = []

    if a:0 == 1 && a:1 ==# '-'
        let l:bPrivate = v:true
    else
        " complex argument parse
        let l:jOption = class#cmdline#new('NoteNew')
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
        let l:sDatePath = a:1
    else
        let l:sDatePath = strftime("%Y/%m/%d")
    endif

    let l:pDirectory = s:jNoteBook.Notedir(l:sDatePath)
    if empty(l:pDirectory)
        return 0
    endif

    let l:pNoteFile = s:jNoteBook.GetLastNote(l:sDatePath)
    if !empty(l:pNoteFile)
        if !isdirectory(l:pDirectory)
            call mkdir(l:pDirectory, 'p')
        endif
        call vnote#GotoNoteWindow()
        execute 'edit ' . l:pNoteFile
    endif
endfunction "}}}
