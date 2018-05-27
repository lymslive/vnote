" notelist tools
" Author: lymslive
" Date: 2017-01-23

" import s:jNoteBook from vnote
let s:jNoteBook = vnote#GetNoteBook()
let s:HEADLINE = 3

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

    let l:jOption = class#viml#cmdline#new('NoteList')
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
    if !s:CheckBuffer()
        return -1
    elseif !s:CheckEntry()
        :WLOG 'please cursor on note entry and press enter'
        return -1
    endif

    " browse mode
    if b:jNoteList.argv[0] =~# '-[DTM]'
        let l:select = getline('.')
        return notelist#hNoteList(b:jNoteList.argv[0], l:select)
    endif

    " list mode
    let l:jNoteEntry = class#notename#new(getline('.'))
    if empty(l:jNoteEntry.string())
        return 0
    endif

    let l:pFileName = l:jNoteEntry.GetFullPath(s:jNoteBook)

    " try goto note window
    let l:iWin = vnote#GotoNoteWindow()
    if l:iWin == 0 && winnr('$') > 1
        :wincmd w
        if &filetype ==? 'notebar'
            :wincmd w
        endif
    endif

    execute 'edit ' . l:pFileName
endfunction "}}}

" PreviewDown:
function! notelist#hPreviewDown() abort "{{{
    :normal! j
    call notelist#hEnterNote()
    call vnote#GotoListWindow()
endfunction "}}}

" PreviewUp:
function! notelist#hPreviewUp() abort "{{{
    :normal! k
    call notelist#hEnterNote()
    call vnote#GotoListWindow()
endfunction "}}}

" ToggleTagLine: show/hide a tag line below a note entry
function! notelist#ToggleTagLine() "{{{
    if !s:CheckBuffer() || !s:CheckEntry()
        return -1
    elseif b:jNoteList.argv[0] !~# '-[tmda]'
        :WLOG 'this map can only be used in normal list mode'
        return -1
    endif

    setlocal modifiable
    call s:_ToggleTagLine()
    setlocal nomodifiable
    return 0
endfunction "}}}
function! s:_ToggleTagLine() "{{{
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
    if !s:CheckBuffer() || !s:CheckEntry()
        return -1
    endif

    " cursor on end of entry line having tag list
    let l:sTag = notelist#DetectTag()
    if !empty(l:sTag) && l:sTag != b:jNoteList.argv[1]
        return notelist#hNoteList(l:sTag)
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

" DetectTag: get the tagname under cursor
" at the end of entry line quoted in [], separated by |
" return empty string if not on tag position
function! notelist#DetectTag() abort "{{{
    let l:sLine = getline('.')
    let l:iPos = match(l:sLine, '^\d.*\t.*\t\zs\[.*\]\ze$')
    if col('.') <= l:iPos
        return ''
    endif

    let l:iCol = col('.') - 1
    let l:idx_left = l:iCol
    let l:idx_right = l:iCol

    while l:idx_left > l:iPos
        let l:char = strpart(l:sLine, l:idx_left, 1)
        if l:char == '|' || l:char == '['
            break
        endif
        let l:idx_left -= 1
    endwhile

    while l:idx_right < col('$') - 1
        let l:char = strpart(l:sLine, l:idx_right, 1)
        if l:char == '|' || l:char == ']'
            break
        endif
        let l:idx_right += 1
    endwhile

    if l:idx_right - l:idx_left > 1
        return strpart(l:sLine, l:idx_left + 1, l:idx_right - l:idx_left - 1)
    else
        return ''
    endif
endfunction "}}}

" CheckEntryMap: return true if key map success on list entry context
function! s:CheckEntry() abort "{{{
    return line('.') > s:HEADLINE
endfunction "}}}
" CheckBuffer: return true if valid notelist buffer
function! s:CheckBuffer() abort "{{{
    return &filetype ==# 'notelist' && exists('b:jNoteList')
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
" a:1, really paste to note in another window, or otherwise
" only yank to default register(") with `` quoted
function! notelist#hPasteTag(yes) abort "{{{
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

    return notelist#PasteTag(l:sTag, a:yes)
endfunction "}}}

" PasteTag: 
function! notelist#PasteTag(tagname, ...) abort "{{{
    let l:sTag = a:tagname
    if empty(l:sTag)
        :WLOG 'can not pick any tag?'
        return -1
    endif

    " yank
    let l:sTagQuote = printf('`%s`', l:sTag)
    call setreg('"', l:sTagQuote)
    :LOG 'the tag have copy to default register: ' . l:sTagQuote

    " paste
    if a:0 > 1 && !empty(a:1)
        let l:iWin = vnote#GotoNoteWindow()
        if l:iWin > 0
            call note#hNoteTag(l:sTag)
        endif
    endif
endfunction "}}}

" ManageTag: handle for NoteTag
" > -d deleted-tag
" > -r old-tag new-tag
" > -m master-tag slave-tag
function! notelist#hManageTag(...) abort "{{{
    if a:0 < 2
        :WLOG 'NoteTag {-d|r|m} {args}'
        return -1
    endif

    let l:sTag = tolower(a:2)
    if l:sTag =~# '/$'
        :ELOG 'cannot operate on tag sub-directory'
        return -1
    endif

    if a:1 ==? '-d'
        let l:jTag = class#notetag#new(l:sTag)
        return l:jTag.Delete()

    elseif a:1 ==? '-r'
        if a:0 < 3
            :WLOG 'NoteTag -r old-tag new-tag'
            return -1
        endif
        let l:jTag = class#notetag#new(l:sTag)
        let l:sNewTag = a:3
        return l:jTag.Rename(l:sNewTag)

    elseif a:1 ==? '-m'
        if a:0 < 3
            :WLOG 'NoteTag -m master-tag slave-tag'
            return -1
        endif

        let l:jTag = class#notetag#new(l:sTag)
        let l:sTagSlave = a:3
        let l:jTagSlave = class#notetag#new(l:sTagSlave)
        return l:jTag.Merge(l:jTagSlave)
    endif
endfunction "}}}

" Delete: handle of delete map
function! notelist#hDelete(...) abort "{{{
    if !s:CheckBuffer() || !s:CheckEntry()
        return -1
    endif

    let l:iErr = 0

    let l:cMode = b:jNoteList.argv[0]
    if l:cMode ==# '-d'
        let l:jNoteEntry = class#notename#new(getline('.'))
        if empty(l:jNoteEntry.string())
            :ELOG 'note not existed'
            return -1
        endif
        let l:pFileName = l:jNoteEntry.GetFullPath(b:jNoteList.notebook)
        let l:reply = input("Confirm to delete note file? [yes|no] ")
        if l:reply !~? '^y'
            return 0
        endif
        let l:iErr = delete(l:pFileName)

    elseif l:cMode ==# '-D'
        let l:sDatePath = note#GetContext()
        let l:pDatePath = b:jNoteList.notebook.Notedir(l:sDatePath)
        let l:reply = input("Confirm to delete all notes? [yes|no] ")
        if l:reply !~? '^y'
            return 0
        endif
        let l:iErr = delete(l:pDatePath, 'rf')

    elseif l:cMode ==# '-t'
        let l:sNoteEntry = getline('.')
        let l:sTag = b:jNoteList.argv[1]
        let l:jNoteTag = class#notetag#new(l:sTag, b:jNoteList.notebook)
        let l:iErr = l:jNoteTag.RemoveEntry(l:sNoteEntry)

    elseif l:cMode ==# '-T'
        let l:sTag = note#GetContext()
        let l:reply = input("Confirm to delete this tag completely? [yes|no] ")
        if l:reply !~? '^y'
            return 0
        endif
        let l:iErr = notelist#hManageTag('-d', l:sTag)

    elseif l:cMode ==# '-m'
        let l:sNoteEntry = getline('.')
        let l:sTag = b:jNoteList.argv[1]
        let l:jNoteTag = class#notetag#mark#new(l:sTag, b:jNoteList.notebook)
        let l:iErr = l:jNoteTag.RemoveEntry(l:sNoteEntry)

    elseif l:cMode ==# '-M'
        let l:sTag = note#GetContext()
        if l:sTag ==# 'mru'
            :ELOG 'can not delet mru bookmark'
            return -1
        endif
        let l:reply = input("Confirm to delete this bookmark completely? [yes|no] ")
        if l:reply !~? '^y'
            return 0
        endif
        let l:jNoteTag = class#notetag#mark#new(l:sTag, b:jNoteList.notebook)
        let l:pTagFile = l:jNoteTag.GetTagFile()
        let l:iErr = delete(l:pTagFile)
    endif

    if l:iErr == 0
        let l:iErr = b:jNoteList.RefreshList(b:jNoteList.argv, 1)
    endif

    return l:iErr
endfunction "}}}

" Rename: handle of rename map
function! notelist#hRename(...) abort "{{{
    " code
endfunction "}}}

" GotoFirstEntry: 
function! notelist#hGotoFirstEntry() abort "{{{
    if !s:CheckBuffer()
        normal! gg
        return 0
    endif

    let l:iFirst = s:HEADLINE + 1
    if line('.') > l:iFirst
        execute 'normal! ' . l:iFirst . 'G'
    else
        normal! gg
    endif
endfunction "}}}

" GotoFinalEntry: 
function! notelist#hGotoFinalEntry() abort "{{{
    if !s:CheckBuffer()
        normal! G
        return 0
    endif

    let l:sLine = getline('.')
    let l:sRegexp = '^\d\+_\d\+'
    if line('.') > s:HEADLINE && l:sLine !~ l:sRegexp
        normal! G
        return
    endif

    let l:iLine = s:HEADLINE + 1
    while l:iLine <= line('$') && getline(l:iLine) =~ l:sRegexp
        let l:iLine += 1
    endwhile
    execute 'normal! ' . (l:iLine-1) . 'G'
endfunction "}}}

" SmartSpace: 
" toggle tag line in note list mode
" edit tag file in browse mode
function! notelist#hSmartSpace() abort "{{{
    if !s:CheckBuffer() || !s:CheckEntry()
        return -1
    endif

    let l:cMode = b:jNoteList.argv[0]
    if l:cMode =~# '-[tmda]'
        return notelist#ToggleTagLine()

    elseif l:cMode =~# '-[TM]'
        let l:sTag = note#GetContext()
        if l:sTag =~# '/$'
            :WLOG 'use <CR> to entry sub tag'
            return 0
        endif

        let l:reply = input("Really edit tag file manually? [yes|no] ")
        if l:reply !~? '^y'
            return 0
        endif

        if l:cMode =~# '-T'
            let l:jNoteTag = class#notetag#new(l:sTag, b:jNoteList.notebook)
        elseif l:cMode =~# '-M'
            let l:jNoteTag = class#notetag#mark#new(l:sTag, b:jNoteList.notebook)
        endif

        if !empty(l:jNoteTag)
            let l:pTagFile = l:jNoteTag.GetTagFile()
            if !empty(l:pTagFile)
                execute 'edit ' . l:pTagFile
                :WLOG 'Caution: eidt a tag file'
            endif
        endif

        return 0
    else
        :ELOG 'can not support <Space> key map in this notelist mode'
        return -1
    endif
endfunction "}}}

" NewNoteWithTag: create a new note with tag under corsor
" > a:1 > private note or note, default public
function! notelist#NewNoteWithTag(...) abort "{{{
    if !s:CheckBuffer()
        return -1
    endif

    let l:sTag = ''
    let l:cMode = b:jNoteList.argv[0]
    if l:cMode ==# '-t'
        let l:sTag = b:jNoteList.argv[1]
    elseif l:cMode ==# '-T'
        if !s:CheckEntry()
            return -1
        endif
        let l:sTag = note#GetContext()
    else
        :WLOG 'can only use in tag list mode -t|-T'
        return -1
    endif

    if empty(l:sTag)
        return -1
    endif

    let l:bPrivate = get(a:000, 0, 0)
    if l:bPrivate || !empty(l:bPrivate)
        call notebook#hNoteNew('-', '-t',  l:sTag)
    else
        call notebook#hNoteNew('-t',  l:sTag)
    endif

    return 0
endfunction "}}}

" ShowHelpKey: Show/Hide help 
function! notelist#hShowHelpKey() abort "{{{
    if !s:CheckBuffer()
        return
    endif
    if s:delete_help()
        return
    else
        let l:lang = get(b:, 'vnote_help_show', 'en')
        call s:append_help(l:lang)
    endif 
endfunction "}}}

" SwitchHelpKey: switch help language en/zh
function! notelist#hSwitchHelpKey() abort "{{{
    let l:lang = get(b:, 'vnote_help_show', '')
    if empty(l:lang)
        :ELOG 'press ? show help first'
        return
    endif
    call s:delete_help()
    if l:lang =~? '^en'
        call s:append_help('zh')
    else
        call s:append_help('en')
    endif
endfunction "}}}

" append_help: 
function! s:append_help(lang) abort "{{{
    let l:pHelp = vnote#GetHelpDoc(a:lang)
    if filereadable(l:pHelp)
        let l:lsContent = readfile(l:pHelp)
        setlocal modifiable
        call append('$', '')
        call append('$', l:lsContent)
        setlocal nomodifiable
        let b:vnote_help_show = a:lang
    else
        :ELOG 'cannot readfile: ' . l:pHelp
    endif
endfunction "}}}

" delete_help: return true if really delete help part
function! s:delete_help() abort "{{{
    let l:sRegexp = '^<!-- HELP .* -->\c'
    let l:iLine = search(l:sRegexp, 'bwc')
    if l:iLine > 0
        setlocal modifiable
        :-1,$ delete
        setlocal nomodifiable
        return 1
    else
        " :ELOG 'help part not found'
        return 0
    endif
endfunction "}}}

" STL: local statusline
function! notelist#STL() abort "{{{
    let l:notelist = get(vnote#GetNoteTab(), 'notelist', {})
    if empty(l:notelist)
        return ':NoteList %=%p%%%LL'
    endif

    let l:argv = ':NoteList ' . join(l:notelist.argv, ' ')

    let l:count = len(l:notelist.entry)
    let l:index = line('.') - s:HEADLINE
    if l:index < 0
        let l:index = 0
    endif
    let l:cursor = printf('%d/%d', l:index, l:count)

    let l:stl = l:argv . '%=' . l:cursor . '|%p%%%LL'
    return l:stl
endfunction "}}}
" Load: call this function to triggle load this script
function! notelist#Load() "{{{
    return 1
endfunction "}}}
