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
" :NoteList [-vhn] [-r] [-dtDT] arg
function! notelist#hNoteList(...) "{{{
    " default argument
    let l:sDatePath = strftime("%Y/%m/%d")
    if a:0 < 1
        let l:argv = [l:sDatePath]
    else
        let l:argv = a:000
    endif

    let l:jOption = class#cmdline#new('NoteList')
    call l:jOption.AddSingle('s', 'split', 'split new window')
    call l:jOption.AddSingle('v', 'vertical', 'vsplit new window')
    call l:jOption.AddSingle('n', 'tabnew', 'tab new window')
    call l:jOption.AddSingle('r', 'resume', 'resume last NoteList')
    let l:iErr = l:jOption.ParseCheck(l:argv, 2)
    if l:iErr != 0
        return l:iErr
    endif

    " try to find a notelist window
    if &filetype != 'notelist'
        let l:iWinnr = vnote#GotoListWindow()
        if l:iWinnr == 0
            if l:jOption.Has('vertical')
                :vsplit
            elseif l:jOption.Has('split')
                :split
            elseif l:jOption.Has('tabnew')
                :tabnew
            endif
        endif
    endif

    " open the lister buffer
    let l:pListerName = s:jNoteBook.GetListerName()
    if expand('%:p') !=# l:pListerName
        execute 'edit ' . l:pListerName
    endif

    if !exists('b:jNoteList') || b:jNoteList.notebook isnot s:jNoteBook
        let b:jNoteList = s:jNoteBook.CreateLister()
        let l:dStatis = vnote#GetStatis()
        let l:dStatis.lister += 1
    endif

    " pass the real lister argument
    let l:lsPostArgv = l:jOption.GetPost()
    if len(l:argv) > 2
        call extend(l:lsPostArgv, l:argv[2:])
    endif
    if empty(l:lsPostArgv)
        call add(l:lsPostArgv, l:sDatePath)
    endif

    if l:jOption.Has('resume')
        " return b:jNoteList.RedrawContent()
        " since notelist buff is hidden, directlly open it to resume
        return b:jNoteList.AjustSeparateLine()
    else
        return b:jNoteList.RefreshList(l:lsPostArgv)
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

" RefineArg: 
function! notelist#hRefineArg() abort "{{{
    if exists('b:jNoteList')
        return ':NoteList ' . join(b:jNoteList.argv)
    else
        return ':'
    endif
endfunction "}}}

" PasteTag: pick and paste current tag to current editing note
function! notelist#hPasteTag() abort "{{{
    if !exists('b:jNoteList')
        :WLOG 'b:jNoteList objcet not ready?'
        return -1
    endif

    let l:sTag = ''
    if b:jNoteList.argv[0] ==# '-t'
        let l:sTag = b:jNoteList.argv[1]
    elseif b:jNoteList.argv[0] ==# '-T'
        if line('.') >= s:HEADLINE
            let l:sTag = getline('.')
        else
            let l:sTag = b:jNoteList.argv[1]
        endif
    else
        :WLOG 'can only pick tag in -t|-T mode'
        return -1
    endif

    if empty(l:sTag)
        :WLOG 'can not pick any tag?'
        return -1
    endif

    let l:iWin = vnote#GotoNoteWindow()
    if l:iWin > 0
        call note#hNoteTag(l:sTag)
    endif

    let l:sTagQuote = printf('`%s`', l:sTag)
    call setreg('"', l:sTagQuote)
    :LOG 'the tag have also copy to default register: ' . l:sTagQuote

    return 0
endfunction "}}}

" Load: call this function to triggle load this script
function! notelist#Load() "{{{
    return 1
endfunction "}}}
