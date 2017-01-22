" notelist filetype tools
" Author: lymslive
" Date: 2017-01-22

" notelist header line relate var
let b:notebook = ''
let b:lister_argument = []

" struct for a note entry line
let s:NoteEntry = {'line':0, 'file':0, 'title':0, 'year':0, 'month':0, 'day':0}

" regexp for match note entry line
let s:entry_line_patter = '^\(\d\{8\}_\d\+.*\)\t\(.*\)'
let s:untag_line_patter = '^\(-\{8,\}\)\t\(.*\)'

nnoremap <buffer> <CR> :call <SID>EnterNote()<CR>
nnoremap <buffer> <Space> :call <SID>ToggleTagLine()<CR>

" s:EnterNote: <CR> to edit note under cursor line
function! s:EnterNote() "{{{
    if !s:ParseEntryLine()
        return 0
    endif

    let l:day_path = s:NoteEntry.year . '/' . s:NoteEntry.month . '/' . s:NoteEntry.day
    let l:note_full_path = b:notebook . '/d/' . l:day_path . '/' . s:NoteEntry.file

    execute 'edit ' . l:note_full_path
endfunction "}}}

" s:ToggleTagLine: 
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
    let l:day_path = s:NoteEntry.year . '/' . s:NoteEntry.month . '/' . s:NoteEntry.day
    let l:note_full_path = b:notebook . '/d/' . l:day_path . '/' . s:NoteEntry.file
    let l:tags = vnote#ReadTags(l:note_full_path)

    let l:tag_line = repeat('-', len(s:NoteEntry.file)) . "\t"
    for l:tag in l:tags
        let l:tag_line = l:tag_line . l:tag . ' '
    endfor

    call append('.', l:tag_line)
    return 1
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
