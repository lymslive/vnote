" notelist tools
" Author: lymslive
" Date: 2017-01-23

" struct for a note entry line
let s:NoteEntry = {'line':0, 'file':0, 'title':0, 'year':0, 'month':0, 'day':0}

" regexp for match note entry line
let s:entry_line_patter = '^\(\d\{8\}_\d\+.*\)\t\(.*\)'
let s:untag_line_patter = '^\(-\{8,\}\)\t\(.*\)'

" map define
nnoremap <Plug>(VNOTE_list_edit_note) :call <SID>EnterNote()<CR>
nnoremap <Plug>(VNOTE_list_toggle_tagline) :call <SID>ToggleTagLine()<CR>
nnoremap <Plug>(VNOTE_list_next_day) :call <SID>NextDay(1)<CR>
nnoremap <Plug>(VNOTE_list_prev_day) :call <SID>NextDay(-1)<CR>
nnoremap <Plug>(VNOTE_list_next_month) :call <SID>NextMonth(1)<CR>
nnoremap <Plug>(VNOTE_list_prev_month) :call <SID>NextMonth(-1)<CR>
nnoremap <Plug>(VNOTE_list_smart_jump) :call <SID>SmartJump()<CR>
nnoremap <Plug>(VNOTE_list_browse_tag) :call notelist#ListNote('-T')<CR>
nnoremap <Plug>(VNOTE_list_browse_date) :call notelist#ListNote('-D')<CR>

" s:EnterNote: <CR> to edit note under cursor line
" open note in another window if possible
function! s:EnterNote() "{{{
    " browse mode
    if b:argv[1] == '-D' || b:argv[1] == '-T'
        let l:select = getline('.')
        return notelist#ListNote(b:argv[1], l:select)
    endif

    " list mode
    if !s:ParseEntryLine()
        return 0
    endif

    let l:dNoteBook = vnote#GetNoteBook()
    let l:day_path = s:NoteEntry.year . '/' . s:NoteEntry.month . '/' . s:NoteEntry.day
    let l:note_full_path = l:dNoteBook.basedir . '/d/' . l:day_path . '/' . s:NoteEntry.file

    if winnr('$') > 1
        wincmd p
    endif

    " wild match suffix of note file
    execute 'edit ' . l:note_full_path . '.*'
endfunction "}}}

" s:ToggleTagLine: show/hide a tag line below a note entry
function! s:ToggleTagLine() "{{{
    let l:lineno = line('.')

    " cursor in tag line, delete it and cursor up one line
    if match(getline('.'), s:untag_line_patter) != -1
        delete
        execute l:lineno - 1
        return 0
    endif

    if !s:ParseEntryLine()
        return 0
    endif

    " next line is tag line, delete it and cursor hold
    if l:lineno < line('$')
        if match(getline(l:lineno+1), s:untag_line_patter) != -1
            normal! j
            delete
            execute l:lineno
            return 0
        endif
    endif

    " show tag of current note entry inserting next line, cursor hold
    let l:dNoteBook = vnote#GetNoteBook()
    let l:day_path = s:NoteEntry.year . '/' . s:NoteEntry.month . '/' . s:NoteEntry.day
    let l:note_full_path = l:dNoteBook.basedir . '/d/' . l:day_path . '/' . s:NoteEntry.file
    let l:tags = notelist#ReadTags(l:note_full_path)

    let l:tag_line = repeat('-', len(s:NoteEntry.file)) . "\t"
    for l:tag in l:tags
        let l:tag_line = l:tag_line . l:tag . ' '
    endfor

    call append('.', l:tag_line)
    return 1
endfunction "}}}

" s:NextDay: list notes of another day
" a:shift, a number, shift how many day, not check beyond month end-days
" use b:argv set by previously call of ListNote function
function! s:NextDay(shift) "{{{
    if b:argv[1] != '-d'
        echo 'Not list note by day?'
        return
    endif

    let l:day_path = b:argv[2]
    let l:day = l:day_path[-2:-1]
    let l:new_day = l:day + a:shift

    if l:new_day <= 0
        let l:new_day = 31
    endif

    if l:new_day > 31
        let l:new_day = 1
    endif

    if l:new_day < 10
        let l:new_day = '0' . l:new_day
    endif

    " replace the last tow digits as day
    let l:new_day_path = substitute(l:day_path, '\d\d$', l:new_day, '')

    call notelist#ListNote(l:new_day_path)
endfunction "}}}

" NextMonth: 
function! s:NextMonth(shift) abort "{{{
    if b:argv[1] != '-d'
        echo 'Not list note by day?'
        return
    endif

    let l:day_path = b:argv[2]
    let l:liDate = split(l:day_path, '/')
    let l:month = l:liDate[1]
    let l:new_month = l:month + a:shift

    if l:new_month <= 0
        let l:new_month = 12
    endif

    if l:new_month > 12
        let l:new_month = 1
    endif

    if l:new_month < 10
        let l:new_month = '0' . l:new_month
    endif

    let l:liDate[1] = l:new_month
    let l:new_day_path = join(l:liDate, '/')

    call notelist#ListNote(l:new_day_path)
endfunction "}}}

" s:ParseEntryLine: parse result save in s:NoteEntry,
" return true if successful, return false if not entry current line
function! s:ParseEntryLine() "{{{
    let l:line = getline('.')
    let l:matches = matchlist(l:line, s:entry_line_patter)
    if len(l:matches) <= 0
        return 0
    endif

    let l:file_name = l:matches[1]
    let l:note_title = l:matches[2]
    let l:year = strpart(l:file_name, 0, 4)
    let l:month = strpart(l:file_name, 4, 2)
    let l:day = strpart(l:file_name, 6, 2)

    let s:NoteEntry.line = line('.')
    let s:NoteEntry.file = l:file_name
    let s:NoteEntry.title = l:note_title
    let s:NoteEntry.year = l:year
    let s:NoteEntry.month = l:month
    let s:NoteEntry.day = l:day

    return 1
endfunction "}}}

" ListNote: list note by date or by tag, depend on argument
" now support one string argument, but may prefix an extra -D or -T option
function! notelist#ListNote(...) "{{{
    if a:0 < 1
        let l:day_path = strftime("%Y/%m/%d")
        return s:ListByDate(l:day_path)
    endif

    if winnr('$') > 1 && &filetype != 'notelist'
        call notelist#FindListWindow()
    endif

    let l:arg = a:1
    if l:arg == '-D'
        return s:BrowseDate(a:000)
    elseif l:arg == '-T'
        return s:BrowseTag(a:000)
    endif

    if match(l:arg, '^\d\d\d\d') != -1
        return s:ListByDate(l:arg)
    else
        return s:ListByTag(l:arg)
    endif

endfunction "}}}

" CreateListBuff: 
" a:argv, string list, the argument of note-list command
" a:content, string list, append this content to buff
function! s:CreateListBuff(argv, content) abort "{{{
    let l:dNoteBook = vnote#GetNoteBook()

    let l:argv = ['note-list']
    call extend(l:argv, a:argv)

    edit _buff_
    call setline(1, '$ note-book ' . l:dNoteBook.basedir)
    call setline(2, '$ ' . join(l:argv, ' '))
    call setline(3, repeat('=', 78))
    call append(line('$'), a:content)
    normal! 4G

    set filetype=notelist
    set buftype=nofile

    let b:notebook = l:dNoteBook
    let b:argv = l:argv
    return 1
endfunction "}}}

" ListByDate: 
" a:date argument as yyyy/mm/dd
function! s:ListByDate(date, ...) abort "{{{
    let l:day_path = a:date

    let l:dNoteBook = vnote#GetNoteBook()
    let l:day_path_full = l:dNoteBook.Notedir(l:day_path)
    let l:note_pattern = l:day_path_full . '/' . '*_*' . l:dNoteBook.suffix
    let l:list_note_file = glob(l:note_pattern, 0, 1)

    let l:output_list = []
    for l:note_file in l:list_note_file
        let l:file_name = strpart(l:note_file, len(l:day_path_full)+1)
        let l:file_name = substitute(l:file_name, l:dNoteBook.suffix . '$', '', '')
        let l:note_title = notelist#ReadTitle(l:note_file)
        call add(l:output_list, l:file_name . "\t" . l:note_title)
    endfor

    return s:CreateListBuff(['-d', l:day_path], l:output_list)
endfunction "}}}

" ListByTag: 
" directly read notebook/t/*.tag file as note list
function! s:ListByTag(tag, ...) abort "{{{
    let l:dNoteBook = vnote#GetNoteBook()
    let l:tag_dir = l:dNoteBook.Tagdir()

    let l:tag_file = l:tag_dir . '/' . a:tag . '.tag'
    if !filereadable(l:tag_file)
        echo 'the notebook has no tag: ' . a:tag
        return 0
    endif
    let l:note_list = readfile(l:tag_file)

    return s:CreateListBuff(['-t', a:tag], l:note_list)
endfunction "}}}

" BrowseDate: 
function! s:BrowseDate(argv) abort "{{{
    let l:argc = len(a:argv)
    if a:argv[0] != '-D'
        echoerr 'argument dismatch'
        return 0
    endif

    if l:argc <= 1
        let l:ArgLead = ''
    else
        let l:ArgLead = a:argv[1]
    endif

    let l:day_path_pattern = '^\d\d\d\d/\d\d/\d\d'
    if match(l:ArgLead, l:day_path_pattern) != -1
        " already full day path
        return s:ListByDate(l:ArgLead)
    else
        let l:dNoteBook = vnote#GetNoteBook()
        let l:day_dir = l:dNoteBook.Filedir()
        if !empty(l:ArgLead) && l:ArgLead[-1] != '/'
            let l:ArgLead = l:ArgLead . '/'
        endif
        let l:day_list = glob(l:day_dir . '/' . l:ArgLead . '*', 0, 1)
        let l:head = len(l:day_dir) + 1
        call map(l:day_list, 'strpart(v:val, l:head)')
        return s:CreateListBuff(a:argv, l:day_list)
    endif
endfunction "}}}

" BrowseTag: 
function! s:BrowseTag(argv) abort "{{{
    let l:argc = len(a:argv)
    if a:argv[0] != '-T'
        echoerr 'argument dismatch'
        return 0
    endif

    if l:argc <= 1
        let l:ArgLead = ''
    else
        let l:ArgLead = a:argv[1]
    endif

    let l:dNoteBook = vnote#GetNoteBook()
    let l:tag_dir = l:dNoteBook.Tagdir()

    if !empty(l:ArgLead) && l:ArgLead[-1] != '/'
        let l:tag_file = l:tag_dir . '/' . l:ArgLead . '.tag'
        if filereadable(l:tag_file)
            " browse a specific tag-file
            return s:ListByTag(l:ArgLead)
        endif
    endif

    let l:head = len(l:tag_dir) + 1
    let l:tag_list = glob(l:tag_dir . '/' . l:ArgLead . '*', 0, 1)

    let l:ret_list = []
    for l:tag in l:tag_list
        let l:tag = strpart(l:tag, l:head)
        if match(l:tag, '\.tag$') != -1
            let l:tag = substitute(l:tag, '\.tag$', '', '')
        else
            let l:tag = l:tag . '/'
        endif
        call add(l:ret_list, l:tag)
    endfor

    return s:CreateListBuff(a:argv, l:ret_list)
endfunction "}}}

" CompleteList: Custom completion for notelist
function! notelist#CompleteList(ArgLead, CmdLine, CursorPos) abort "{{{
    let l:dNoteBook = vnote#GetNoteBook()

    if empty(a:ArgLead) || match(a:ArgLead, '^\d\d') == -1
        " compelete tag
        let l:tag_dir = l:dNoteBook.Tagdir()
        let l:head = len(l:tag_dir) + 1
        let l:tag_list = glob(l:tag_dir . '/' . a:ArgLead . '*', 0, 1)

        let l:ret_list = []
        for l:tag in l:tag_list
            let l:tag = strpart(l:tag, l:head)
            if match(l:tag, '\.tag$') != -1
                let l:tag = substitute(l:tag, '\.tag$', '', '')
            else
                let l:tag = l:tag . '/'
            endif
            call add(l:ret_list, l:tag)
        endfor

        return l:ret_list

    else
        " compelete date
        let l:day_path_pattern = '^\d\d\d\d/\d\d/\d\d'
        if match(a:ArgLead, l:day_path_pattern) != -1
            " already full day path
            return []
        else
            let l:day_dir = l:dNoteBook.Filedir()
            let l:head = len(l:day_dir) + 1
            let l:day_list = glob(l:day_dir . '/' . a:ArgLead . '*', 0, 1)
            let l:ret_list = []
            for l:day in l:day_list
                let l:day = strpart(l:day, l:head)
                call add(l:ret_list, l:day)
            endfor
            return l:ret_list
        endif
    endif
endfunction "}}}

" SmartJump: 
" when open tag line and cursor on a tag, switch list by this tag
" or when cursor on note entry, switch list by its date
" igore the same tag or date
function! s:SmartJump() abort "{{{
    let l:line = getline('.')
    if match(l:line, '^\d\{8\}') != -1
        let l:day_int = strpart(l:line, 0, 8)
        let l:day_path = strpart(l:day_int, 0, 4) . '/' . strpart(l:day_int, 4, 2) . '/' . strpart(l:day_int, 6, 2) 
        if l:day_path != b:argv[2]
            return s:ListByDate(l:day_path)
        endif
    else
        let l:tag = note#DetectTag(0)
        if !empty(l:tag) && l:tag != b:argv[2]
            return s:ListByTag(l:tag)
        endif
    endif
    return 0
endfunction "}}}

" FindListWindow: find and jump to a window that set filetype=notelist
" return: the window nr or 0 if not found
" action: may change the current window if found
function! notelist#FindListWindow() abort "{{{
    let l:old = winnr()
    let l:new = 0

    let l:count = winnr('$')
    for l:win in range(1, l:count)
        execute l:win . 'wincmd w'
        if &filetype == 'notelist'
            let l:new = l:win
            break
        endif
    endfor

    if l:new == 0 && l:win != l:old
        execute l:old . 'wincmd w'
    endif

    return l:new
endfunction "}}}

" ReadTitle: get the tile of a note file from first line
" a:1 full path of note file
function! notelist#ReadTitle(file) "{{{
    let l:note_file = a:file
    if !filereadable(l:note_file)
        return ''
    endif

    let l:file_lines = readfile(l:note_file, '', 1)
    let l:first_line = l:file_lines[0]
    let l:note_title = substitute(l:first_line, '^\s*#\s*', '', '')
    return l:note_title
endfunction "}}}

" ReadTags: return a list of tags of one note
" a:1 full path of note file
" return list, one item each tag line, may including multy ``
function! notelist#ReadTags(file) "{{{
    let l:note_file = a:file
    if match(l:note_file, '.\..\+$') == -1
        let l:note_file = l:note_file . '.md'
    endif

    if !filereadable(l:note_file)
        return []
    endif

    let l:tags = []
    let l:tag_on = 0
    let l:tag_off = 0

    let l:file_lines = readfile(l:note_file, '', 10)
    for l:line in l:file_lines
        if strlen(l:line) < 3
            continue
        endif

        if l:tag_off
            break
        endif

        if l:line[0] == '`' && l:line[1] != '`'
            call add(l:tags, l:line)
            let l:tag_on = 1
        else
            if l:tag_on
                let l:tag_off = 1
            endif
        endif

    endfor

    return l:tags
endfunction "}}}

" Load: call this function to triggle load this script
function! notelist#Load() "{{{
    return 1
endfunction "}}}
