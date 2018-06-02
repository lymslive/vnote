" note tools -- edit markdown note file
" Author: lymslive
" Modify: 2017-03-15

" import s:jNoteBook from vnote
let s:jNoteBook = vnote#GetNoteBook()

" GetNoteObject: get the class#notebuff objcet associate with current buffer
function! s:GetNoteObject() abort "{{{
    if !exists('b:jNoteBuff')
        if !s:NoteInBook()
            :DLOG 'this file not is current notebook, refuse to create note object'
            return {}
        endif
        let b:jNoteBuff = class#notebuff#new(s:jNoteBook)
    endif
    return b:jNoteBuff
endfunction "}}}

" NoteInBook: true if current buffer is in current notebook
function! s:NoteInBook() abort "{{{
    return expand('%:p') =~ '^' . s:jNoteBook.Datedir()
endfunction "}}}
" IsInBook: 
function! note#IsInBook() abort "{{{
    return s:NoteInBook()
endfunction "}}}

" EditNext: edit next note of the same day
function! note#EditNext(shift) "{{{
    if !s:NoteInBook()
        return 0
    endif

    let l:jNoteName = class#notename#new(expand('%:t'))
    let l:sDatePath = l:jNoteName.GetDatePath()

    let l:iNoteNumber = l:jNoteName.number()
    let l:iNoteNumber += a:shift

    echo l:iNoteNumber
    if l:iNoteNumber <= 0
        return -1
    endif

    " get a note file name, may be new non-exists one, then edit it
    let l:pNoteFile = s:jNoteBook.FindNoteByDateNo(l:sDatePath, l:iNoteNumber, 1)
    execute 'edit ' l:pNoteFile
endfunction "}}}

" OpenNoteList: call ListNote with tag under cursor or current day
function! note#OpenNoteList() abort "{{{
    if !s:NoteInBook()
        echo 'not in notebook?'
        return 0
    endif

    let l:sTag = note#DetectTag(1)
    if empty(l:sTag)
        let l:jNoteName = class#notename#new(expand('%:t'))
        let l:sDatePath = l:jNoteName.GetDatePath()
        call notelist#hNoteList(l:sDatePath)
    else
        call notelist#hNoteList(l:sTag)
    endif

endfunction "}}}

" SmartTab: 
function! note#hSmartTab() abort "{{{
    if winnr('$') > 1
        let l:iWin = vnote#GotoListWindow()
        if l:iWin == 0
            :wincmd p
        endif
    else
        :vsplit
        call note#OpenNoteList()
    endif
endfunction "}}}

" DetectTag: get a tag under cursor, the string between two `` marks
" a:bol, begin of line, require the mark at bol or not
function! note#DetectTag(bol) abort "{{{
    let l:line = getline('.')
    if a:bol && match(l:line, '^\s*`.*`') == -1
        return ''
    endif

    let l:col_pos = col('.')
    let l:col_idx = l:col_pos - 1

    " use stack algorithm to find the `` pair around cursor
    let l:quote_stack = []
    let l:quote_left = -1
    let l:quote_right = -1
    for l:idx in range(len(l:line))
        if l:line[l:idx] != '`'
            continue
        endif

        if empty(l:quote_stack)
            if l:idx <= l:col_idx
                call add(l:quote_stack, l:idx)
            else
                " already beyond right out the cursor
                break
            endif
        else
            if l:idx >= l:col_idx
                let l:quote_left = remove(l:quote_stack, -1)
                let l:quote_right = l:idx
            else
                call remove(l:quote_stack, -1)
            endif
        endif
    endfor

    " extract the tag string in ``
    if l:quote_left == -1 || l:quote_right == -1
        return ''
    elseif l:quote_right - l:quote_left <= 1
        return ''
    else
        return strpart(l:line, l:quote_left+1, l:quote_right-l:quote_left - 1)
    endif
endfunction "}}}

" OnSaveNote: triggle by some write event
" when cursor on the first 2 lines, force save as consider it just
" has modified title or tags
function! note#OnSaveNote(...) abort "{{{
    let l:jNoteBuff = s:GetNoteObject()
    if empty(l:jNoteBuff)
        return 0
    endif

    let l:sForce = get(a:000, 0, '')
    if empty(l:sForce)
        if line('.') <= 2
            let l:sForce = 1
        endif
    endif

    return l:jNoteBuff.SaveNote(l:sForce)
endfunction "}}}
" OnBufRead: 
function! note#OnBufRead() abort "{{{
    let l:jNoteBuff = s:GetNoteObject()
    if empty(l:jNoteBuff)
        return 0
    endif
    call l:jNoteBuff.MarkSaved()
    return l:jNoteBuff.PushMru()
endfunction "}}}

" NoteTag: 
function! note#hNoteTag(...) abort "{{{
    if !s:NoteInBook()
        return 0
    endif

    let l:jNoteBuff = s:GetNoteObject()

    if a:0 == 0
        return l:jNoteBuff.UpdateTagFile()
    elseif a:1 == 1
        return l:jNoteBuff.AddTag(a:1)
    else
        if a:1 ==# '-d'
            let l:lsTag = a:000[1:]
            return l:jNoteBuff.RemoveTag(l:lsTag)
        else
            let l:lsTag = a:000
            return l:jNoteBuff.AddTag(l:lsTag)
        endif
    endif
endfunction "}}}

" NoteMark: 
function! note#hNoteMark(...) abort "{{{
    if !s:NoteInBook()
        return 0
    endif

    let l:jNoteBuff = s:GetNoteObject()

    if a:0 == 0
        return l:jNoteBuff.AddBookMark('default')
    elseif a:1 == 1
        return l:jNoteBuff.AddBookMark(a:1)
    else
        for l:sTag in a:000
            call l:jNoteBuff.AddBookMark(l:sTag)
        endfor
    endif
endfunction "}}}

" NoteNew: create new note with the same tag set as current one
function! note#hNoteNew(...) abort "{{{
    if a:0 == 0
        if !exists('b:jNoteBuff') || b:jNoteBuff.saved != v:true
            :ELOG 'you should save current note first'
            return -1
        endif
        let l:tagLine = getline(2)
        let l:sNoteName = b:jNoteBuff.GetNoteName()
        if l:sNoteName =~# '-$'
            call notebook#hNoteNew('-')
        else
            call notebook#hNoteNew()
        endif
        call setline(2, l:tagLine)
    else
        call call(function('notebook#hNoteNew'), a:000)
    endif
endfunction "}}}

" GetContext: get the first word of current line
function! note#GetContext() abort "{{{
    let l:sLine = getline('.')
    return split(l:sLine, '\s\+')[0]
endfunction "}}}

" Test: 
function! note#Test() abort "{{{
    " echo s:DetectTag()
    if !s:NoteInBook()
        echo 'not in notebook?'
    else
        echo 'yes in notebook'
    endif
    return 1
endfunction "}}}
