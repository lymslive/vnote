" notelist tools
" Author: lymslive
" Date: 2017-01-23

" import s:jNoteBook from vnote
let s:jNoteBook = vnote#GetNoteBook()
let s:HEADLINE = 4

" regexp for match note entry line
let s:entry_line_patter = '^\(\d\{8\}_\d\+.*\)\t\(.*\)'
let s:untag_line_patter = '^\(-\{8,\}\)\t\(.*\)'

" ListNote: list note by date or by tag, depend on argument
" now support one string argument, but may prefix an extra -D or -T option
function! notelist#hNoteList(...) "{{{
    if a:0 < 1
        let l:sDatePath = strftime("%Y/%m/%d")
        let l:argv = [l:sDatePath]
    else
        let l:argv = a:000
    endif

    if winnr('$') > 1 && &filetype != 'notelist'
        call notelist#FindListWindow()
    endif

    if exists('b:jNoteList')
        return b:jNoteList.RefreshList(l:argv)
    else
        let l:jNoteList = class#notelist#new(s:jNoteBook)
        let l:iRet = l:jNoteList.RefreshList(l:argv)
        if l:iRet == 0
            let b:jNoteList = l:jNoteList
            return 0
        else
            return -1
        endif
    endif
endfunction "}}}

" BackList: back to list a top level
function! notelist#hBackList() abort "{{{
    if &filetype !=# 'notelist' || !exists('b:jNoteList')
        :ELOG '[notelist] not in notelist buffer??'
        return -1
    endif
    return b:jNoteList.BackList()
endfunction "}}}

" EnterNote: <CR> to edit note under cursor line
" open note in another window if possible
function! notelist#hEnterNote() "{{{
    if !s:CheckEntryMap()
        return -1
    endif

    " browse mode
    if b:jNoteList.argv[0] ==# '-D' || b:jNoteList.argv[0] ==# '-T'
        let l:select = getline('.')
        return notelist#hNoteList(b:jNoteList.argv[0], l:select)
    endif

    " list mode
    let l:jNoteEntry = class#notename#new(getline('.'))
    if empty(l:jNoteEntry.string())
        return 0
    endif

    let l:pFileName = l:jNoteEntry.GetFullPath(s:jNoteBook)

    if winnr('$') > 1
        :wincmd p
    endif

    execute 'edit ' . l:pFileName
endfunction "}}}

" ToggleTagLine: show/hide a tag line below a note entry
function! notelist#ToggleTagLine() "{{{
    if !s:CheckEntryMap()
        return -1
    endif

    let l:lineno = line('.')

    " cursor in tag line, delete it and cursor up one line
    if match(getline('.'), s:untag_line_patter) != -1
        delete
        execute l:lineno - 1
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

    let l:jNoteEntry = class#notename#new(getline('.'))
    if empty(l:jNoteEntry.string())
        return -1
    endif

    let l:pFileName = l:jNoteEntry.GetFullPath(s:jNoteBook)
    let l:jNoteFile = class#note#new(l:pFileName)
    let l:sTagLine = l:jNoteFile.GetTagLine()

    let l:sLeadLine = repeat('-', len(l:jNoteEntry.string()))
    call append('.', l:sLeadLine . "\t" . l:sTagLine)

    return 0
endfunction "}}}

" SmartTab: vsplit windown to open note or switch window 
function! notelist#hSmartTab() abort "{{{
    if winnr('$') > 1
        :wincmd p
    else
        :vsplit
        call notelist#hEnterNote()
    endif
endfunction "}}}

" NextDay: list notes of another day
" a:shift, a number, shift how many day, not check beyond month end-days
function! notelist#NextDay(shift) "{{{
    if !exists('b:jNoteList') || b:jNoteList.argv[0] !=# '-d'
        :WLOG 'Not list note by day?'
        return 0
    endif

    let l:sDatePath = b:jNoteList.argv[1]
    let l:jDate = class#date#new(l:sDatePath)
    call l:jDate.ShiftDay(a:shift)
    let l:sDatePath = l:jDate.string('/')

    call notelist#hNoteList(l:sDatePath)
endfunction "}}}

" NextMonth: 
function! notelist#NextMonth(shift) abort "{{{
    if !exists('b:jNoteList') || b:jNoteList.argv[0] !=# '-d'
        :WLOG 'Not list note by day?'
        return 0
    endif

    let l:sDatePath = b:jNoteList.argv[1]
    let l:jDate = class#date#new(l:sDatePath)
    call l:jDate.ShiftMonth(a:shift)
    let l:sDatePath = l:jDate.string('/')

    call notelist#hNoteList(l:sDatePath)
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
function! notelist#hSmartJump() abort "{{{
    if !s:CheckEntryMap()
        return -1
    endif

    " cursor in entry line?
    let l:jNoteEntry = class#notename#new(getline('.'))
    if !empty(l:jNoteEntry.string())
        let l:sDatePath = l:jNoteEntry.GetDatePath()
        if l:sDatePath !=# b:jNoteList.argv[1]
            return notelist#hNoteList(l:sDatePath)
        endif
    endif

    " cursor on opend tag line
    let l:sTag = note#DetectTag(0)
    if !empty(l:sTag) && l:sTag != b:jNoteList.argv[1]
        return notelist#hNoteList(l:sTag)
    endif

    return 0
endfunction "}}}

" FindListWindow: find and jump to a window that set filetype=notelist
" return: the window nr or 0 if not found
" action: may change the current window if found
function! notelist#FindListWindow() abort "{{{
    let l:count = winnr('$')
    for l:win in range(1, l:count)
        if getwinvar(l:win, '&filetype') ==# 'notelist'            
            execute l:win . 'wincmd w'
            return l:win
        endif
    endfor

    return 0
endfunction "}}}

" CheckEntryMap: return true if key map success on list entry context
function! s:CheckEntryMap() abort "{{{
    if !exists('b:jNoteList') || &filetype !=# 'notelist'
        echo 'Not notelist buffer?'
        return v:false
    endif

    if line('.') < s:HEADLINE
        return v:false
    endif

    return v:true
endfunction "}}}

" Load: call this function to triggle load this script
function! notelist#Load() "{{{
    return 1
endfunction "}}}
