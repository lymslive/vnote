" note tools -- edit markdown note file
" Author: lymslive
" Date: 2017/01/23

" map define
nnoremap <Plug>(VNOTE_edit_next_note) :call <SID>EditNext(1)<CR>
nnoremap <Plug>(VNOTE_edit_prev_note) :call <SID>EditNext(-1)<CR>
nnoremap <Plug>(VNOTE_edit_open_list) :call <SID>OpenNoteList()<CR>
nnoremap <Plug>(VNOTE_edit_smart_tab) :call note#hSmartTab()<CR>

" import s:jNoteBook from vnote
let s:jNoteBook = vnote#GetNoteBook()

" GetNoteObject: get the class#notebuff objcet associate with current buffer
function! s:GetNoteObject() abort "{{{
    if !exists('b:jNoteBuff')
        let b:jNoteBuff = class#notebuff#new()
    endif
    return b:jNoteBuff
endfunction "}}}

" NoteInBook: true if current buffer is in current notebook
function! s:NoteInBook() abort "{{{
    let l:jNoteBuff = s:GetNoteObject()
    return l:jNoteBuff.IsinBook(s:jNoteBook)
endfunction "}}}

" EditNext: edit next note of the same day
function! s:EditNext(shift) "{{{
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
function! s:OpenNoteList() abort "{{{
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
        let l:iWin = notelist#FindListWindow()
        if l:iWin == 0 && l:iWin == winnr()
            :wincmd p
        endif
    else
        :vsplit
        call s:OpenNoteList()
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

" UpdateTagFile: update each tag file of current note
function! s:UpdateTagFile() abort "{{{
    if !s:NoteInBook()
        return 0
    endif

    let l:jNoteBuff = s:GetNoteObject()
    let l:lsTag = l:jNoteBuff.GetTagList()
    if empty(l:lsTag)
        return 0
    endif

    " note entry of current note
    let l:sNoteName = l:jNoteBuff.GetNoteName()
    let l:sTitle = l:jNoteBuff.GetNoteTitle()
    let l:sNoteEntry = l:sNoteName . "\t" . l:sTitle

    let l:pTagDir = s:jNoteBook.Tagdir()
    if !isdirectory(l:pTagDir)
        call mkdir(l:pTagDir, 'p')
    endif

    for l:sTag in l:lsTag
        " read in old notelist of that tag
        let l:pTagFile = l:pTagDir . '/' . l:sTag . '.tag'
        if filereadable(l:pTagFile)
            let l:lsNote = readfile(l:pTagFile)
        else
            let l:lsNote = []
        endif

        let l:bFound = v:false
        for l:note in l:lsNote
            if match(l:note, '^' . l:sNoteName) != -1
                let l:bFound = v:true
                break
            endif
        endfor

        if l:bFound == v:false
            call add(l:lsNote, l:sNoteEntry)

            " complex tag, treat as path
            if match(l:sTag, '/') != -1
                let l:idx = len(l:pTagFile) - 1
                while l:idx >= 0
                    if l:pTagFile[l:idx] == '/'
                        break
                    endif
                    let l:idx = l:idx - 1
                endwhile
                " trim the last /
                let l:pTagDir = strpart(l:pTagFile, 0, l:idx)
                if !isdirectory(l:pTagDir)
                    call mkdir(l:pTagDir, 'p')
                endif
            endif

            call writefile(l:lsNote, l:pTagFile)
            echo 'update tag file: ' . l:sTag
        endif
    endfor

    return 0
endfunction "}}}

" UpdateNote: save note and tag file if context possible 
function! note#UpdateNote() abort "{{{
    " save this note file
    :update

    if !s:NoteInBook()
        return 0
    endif

    " save relate tag file only if cursor on tag line
    let l:sLine = getline('.')
    if match(l:sLine, '^\s*`') != -1
        call s:UpdateTagFile()
    endif

    return 1
endfunction "}}}

" Load: 
function! note#Load() "{{{
    return 1
endfunction "}}}

" note#Test: 
function! note#Test() abort "{{{
    " echo s:DetectTag()
    if !s:NoteInBook()
        echo 'not in notebook?'
    else
        echo 'yes in notebook'
    endif
    return 1
endfunction "}}}
