" note tools -- edit markdown note file
" Author: lymslive
" Date: 2017/01/23

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
        let l:iWin = notelist#FindListWindow()
        if l:iWin == 0 && l:iWin == winnr()
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

" UpdateNote: triggle by some write event
function! note#OnSaveNote() abort "{{{
    " :update

    if !s:NoteInBook()
        return 0
    endif

    let l:jNoteBuff = s:GetNoteObject()
    let l:iRet = 0
    if vnote#GetConfig().always_update_tag
        let l:iRet = l:jNoteBuff.UpdateTagFile(s:jNoteBook)
    else
        " save relate tag file only if cursor on tag line
        let l:sLine = getline('.')
        if match(l:sLine, '^\s*`') != -1
            let l:iRet = l:jNoteBuff.UpdateTagFile(s:jNoteBook)
        endif
    endif

    return l:iRet
endfunction "}}}

" Todo: modify todo item
function! note#hTodo(...) abort "{{{
    let l:iProgress = 0
    let l:sText = ''

    if a:0 > 2
        let l:iProgress = 0 + a:1
        let l:sText = a:2
    elseif a:0 == 1
        if a:1 =~ '^\d'
            let l:iProgress = 0 + a:1
        else
            let l:sText = a:1
        endif
    endif

    let l:sLine = getline('.')
    " modify current todo's progress
    let l:sTodoPattern = '^[-+*]\s\+\[todo\(:\d\+%\?\)\?\]'
    if l:sLine =~ l:sTodoPattern
        if l:iProgress >= 100
            let l:sTodoLabel = printf('+ [todo:%d%%]', 100)
            let l:sLine = substitute(l:sLine, l:sTodoPattern, l:sTodoLabel, '')
        elseif l:iProgress > 0
            let l:sTodoLabel = printf('* [todo:%d%%]', l:iProgress)
            let l:sLine = substitute(l:sLine, l:sTodoPattern, l:sTodoLabel, '')
        else
            let l:sTodoLabel = '- [todo]'
            let l:sLine = substitute(l:sLine, l:sTodoPattern, l:sTodoLabel, '')
        endif
        call setline('.', l:sLine)
        normal! $
        return 0
    endif

    " add new todo item
    let l:sInsert = '- [todo]'
    if !empty(l:sText)
        let l:sInsert .= l:sText
    endif

    if l:sLine =~ '^\s*[-+*]\?\s*$'
        let l:bReplace = v:true
        call setline('.', l:sInsert)
        normal! $
    else
        let l:bReplace = v:false
        call append('.', l:sInsert)
        normal! j$
    endif

endfunction "}}}

" Todo_i: 
function! note#hTodo_i() abort "{{{
    let l:sCmd = "\<ESC>:TODO\<CR>a"
    return l:sCmd
endfunction "}}}

" EnterNormal: for nmap <expr> <CR>
function! note#hEnterExpr() abort "{{{
    let l:sTodoPattern = '^[-+*]\s\+\[todo\(:\d\+%\?\)\?\]'
    let l:sLine = getline('.')
    if l:sLine =~ l:sTodoPattern
        return ':TODO '
    else
        return ':Note'
    endif
endfunction "}}}

" EnterNormal_i: for imap <expr> <CR>
function! note#hEnterExpr_i() abort "{{{
    let l:sLine = getline('.')
    if col('.') <= len(l:sLine)
        return "\<CR>"
    endif

    let l:sTodoPattern = '^[-+*]\s\+\[todo\(:\d\+%\?\)\?\]'
    if l:sLine =~ l:sTodoPattern
        return "\<CR>- [todo] "
    elseif l:sLine =~ '^\s*[-+*]\s\+'
        return "\<CR>" . matchstr(l:sLine, '^\s*[-+*]\s\+')
    else
        return "\<CR>"
    endif
endfunction "}}}

" NoteTag: 
function! note#hNoteTag(...) abort "{{{
    let l:jNoteBuff = s:GetNoteObject()

    if a:0 == 0
        return l:jNoteBuff.UpdateTagFile()
    elseif a:1 == 1
        return l:jNOteBuff.AddTag(a:1)
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
