" Class: class#notelist
" Author: lymslive
" Description: notelist manager
" Create: 2017-02-16
" Modify: 2017-02-16

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" note-list buffer name
let s:bufferName = '_NLS_'

" CLASS:
let s:class = class#old()
let s:class._name_ = 'class#notelist'
let s:class._version_ = 1

" which notebook this list belong to
let s:class.notebook = {}

" the argument of note-list
let s:class.argv = []

function! class#notelist#class() abort "{{{
    return s:class
endfunction "}}}

" NEW:
function! class#notelist#new(...) abort "{{{
    let l:obj = copy(s:class)
    call l:obj._new_(a:000)
    return l:obj
endfunction "}}}

" CTOR:
function! class#notelist#ctor(this, argv) abort "{{{
    if len(a:argv) > 0
        call a:this.SetNoteBook(a:argv[0])
    else
        echoerr 'expect a class#notebook to construct a class#notelist object'
    endif
    let a:this.argv = []
endfunction "}}}

" SetNoteBook: 
function! s:class.SetNoteBook(jNoteBook) dict abort "{{{
    if class#notebook#isobject(a:jNoteBook)
        let self.NoteBook = a:jNoteBook
        return 0
    else
        echoerr 'expect an object of class#notebook'
        return -1
    endif
endfunction "}}}

" RefreshList: 
function! s:class.RefreshList(argv) dict abort "{{{
    " set option schema
    let l:jOption = class#cmdline#new('NoteList')
    call l:jOption.AddSingle('d', 'date', 'note in this date')
    call l:jOption.AddSingle('t', 'tag', 'note has this tag')
    call l:jOption.AddSingle('D', 'Date-Tree', 'browse by date')
    call l:jOption.AddSingle('T', 'Tag-Tree', 'browse by tag')

    " parser a:argv
    let l:iErr = l:jOption.Check(a:argv)
    if l:iErr != 0
        return l:iErr
    endif

    " let self.argv = a:argv
    let l:lsPostArgv = l:jOption.GetPost()

    " get the first argument
    let l:sArg = ''
    let l:iPostArgc = len(l:lsPostArgv)
    if l:iPostArgc > 0
        let l:sArg = l:lsPostArgv[0]
    endif

    " dispatch note-list mode
    let l:lsContent = []
    if l:jOption.Has('Date-Tree')
        let l:lsContent = self.BrowseDate(l:sArg)
    elseif l:jOption.Has('Tag-Tree')
        let l:lsContent = self.BrowseTag(l:sArg)
    elseif l:jOption.Has('date')
        let l:lsContent = self.ListByDate(l:sArg)
    elseif l:jOption.Has('tag')
        let l:lsContent = self.ListByTag(l:sArg)
    else
        if match(l:sArg, self.notebook.pattern.datePath) != -1
            let l:lsContent = self.ListByDate(l:sArg)
        else
            let l:lsContent = self.ListByTag(l:sArg)
        endif
    endif

    return self.RedrawContent(l:lsContent)
endfunction "}}}

" RedrawContent: 
function! s:class.RedrawContent(lsContent) dict abort "{{{
    " may need edit a new buffer
    if &filetype !=# 'notelist'
        let l:pBuffer = self.GetBufferName()
        execute ':edit ' . l:pBuffer
    endif

    " clear old content
    :1,$delet

    " set buffer content
    call setline(1, '$ note-book ' . self.noteBook.basedir)
    call setline(2, '$ note-list ' . join(self.argv))
    call setline(3, repeat('=', 78))
    call append(line('$'), a:lsrContent)

    " put cursor
    normal! 4G

    " set type for new buffer
    if &filetype !=# 'notelist'
        set filetype=notelist
        set buftype=nofile
    endif

    return 0
endfunction "}}}

" GetBufferName: return a file name for note-list buffer
function! s:class.GetBufferName() dict abort "{{{
    let l:jNoteBook = self.notebook
    let l:pBuffer = l:jNoteBook.Cachedir() . '/' . s:bufferName
    return l:pBuffer
endfunction "}}}

" ListByDate: note-list -d {yyyy/mm/dd}
function! s:class.ListByDate(sDatePath, ...) dict abort "{{{
    let l:pDiretory = self.notebook.Notedir(a:sDatePath)
    let l:sNoteGlob = l:pDiretory . '/*_*' . self.notebook.suffix 
    let l:lpNoteFile = glob(l:sNoteGlob, 0, 1)

    let l:lsOutput = []
    for l:pNote in l:lpNoteFile
        let l:pFileName = strpart(l:pNote, len(l:pDiretory)+1)
        let l:sNoteID = substitute(l:pFileName, self.notebook.suffix . '$', '', '')
        let l:jNote = class#note(l:pNote)
        let l:sNoteTitle = l:jNote.GetNoteTitle()
        call add(l:lsOutput, l:sNoteID . "\t" . l:sNoteTitle)
    endfor

    let self.argv = ['-d', a:sDatePath]
    return l:lsOutput
endfunction "}}}

" ListByTag: note-list -t {tag-name}
function! s:class.ListByTag(sTag, ..) dict abort "{{{
    let l:pDiretory = self.notebook.Tagdir()
    let l:pTagFile = l:pDiretory . '/' . a:sTag . '.tag'
    if !filereadable(l:pTagFile)
        echo 'the notebook has no tag: ' . a:sTag
        return []
    endif

    let self.argv = ['-t', a:sTag]
    return readfile(l:pTagFile)
endfunction "}}}

" BrowseDate: note-list -D [yyyy/mm]
function! s:class.BrowseDate(ArgLead) dict abort "{{{
    " full yyyy/mm/dd date path
    if match(a:ArgLead, self.notebook.pattern.datePath) != -1
        return self.ListByDate(a:ArgLead)
    endif

    " partial yyyy/mm path
    let l:pDiretory = self.notebook.Datedir()
    if !empty(a:ArgLead) && a:ArgLead[-1] != '/'
        let l:ArgLead = a:ArgLead . '/'
    else
        let l:ArgLead = a:ArgLead
    endif

    let l:lpDate = glob(l:pDiretory . '/' . l:ArgLead . '*', 0, 1)
    let l:iHead = len(l:pDiretory) + 1
    call map(l:lpDate, 'strpart(v:val, l:iHead)')

    let self.argv = ['-D', a:ArgLead]
    return l:lpDate
endfunction "}}}

" BrowseTag: 
function! s:class.BrowseTag(ArgLead) dict abort "{{{
    let l:pDiretory = self.notebook.Tagdir()

    " check browse a specific tag-file
    if !empty(a:ArgLead) && a:ArgLead[-1] != '/'
        let l:pTagFile = l:pDiretory . '/' . a:ArgLead . '.tag'
        if filereadable(l:pTagFile)
            return self.ListByTag(a:ArgLead)
        endif
    endif

    let l:iHead = len(l:pDiretory) + 1
    let l:lpTag = glob(l:pDiretory . '/' . a:ArgLead . '*', 0, 1)

    let l:lsRet = []
    for l:pTag in l:lpTag
        let l:sTag = strpart(l:pTag, l:iHead)
        if match(l:sTag, '\.tag$') != -1
            let l:sTag = substitute(l:sTag, '\.tag$', '', '')
        else
            let l:sTag = l:sTag . '/'
        endif
        call add(l:lsRet, l:sTag)
    endfor

    let self.argv = ['-T', a:ArgLead]
    return l:lsRet
endfunction "}}}

" LOAD:
let s:load = 1
echo 'class#notelist is loading ...'
function! class#notelist#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1) && exists('s:load')
        unlet s:load
        return 0
    endif
    return s:load
endfunction "}}}

" TEST:
function! class#notelist#test(...) abort "{{{
    return 0
endfunction "}}}
