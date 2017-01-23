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

" s:EnterNote: <CR> to edit note under cursor line
function! s:EnterNote() "{{{
    if !s:ParseEntryLine()
        return 0
    endif

    let l:dNoteBook = vnote#GetNoteBook()
    let l:day_path = s:NoteEntry.year . '/' . s:NoteEntry.month . '/' . s:NoteEntry.day
    let l:note_full_path = l:dNoteBook.basedir . '/d/' . l:day_path . '/' . s:NoteEntry.file

    execute 'edit ' . l:note_full_path
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

" s:NextDay: list another's notes
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
    " replace the last tow digits as day
    let l:new_day_path = substitute(l:day_path, '\d\d$', l:new_day, '')

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

" ListNote: list note of a day (default today)
" a:1, date argument as yyyy/mm/dd
function! notelist#ListNote(...) "{{{
    if a:0 < 1
        let l:day_path = strftime("%Y/%m/%d")
    else
        let l:day_path = a:1
    endif

    let l:dNoteBook = vnote#GetNoteBook()
    let l:day_path_full = l:dNoteBook.Notedir(l:day_path)
    let l:note_pattern = l:day_path_full . '/' . '*_*' . l:dNoteBook.suffix
    let l:list_note_file = glob(l:note_pattern, 0, 1)

    let l:output_list = []
    for l:note_file in l:list_note_file
        let l:file_name = strpart(l:note_file, len(l:day_path_full)+1)
        let l:note_title = notelist#ReadTitle(l:note_file)
        call add(l:output_list, l:file_name . "\t" . l:note_title)
    endfor

    edit _buff_
    call setline(1, '$ note-book ' . l:dNoteBook.basedir)
    call setline(2, '$ note-list -d ' . l:day_path)
    call setline(3, repeat('=', 78))
    call append(line('$'), l:output_list)
    normal! 4G

    set filetype=notelist
    set buftype=nofile

    let b:notebook = l:dNoteBook
    let b:argv = ['note-list', '-d', l:day_path]
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
