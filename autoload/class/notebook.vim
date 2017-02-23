" Class: class#notebook
" Author: lymslive
" Description: notebook manager
" Create: 2017-02-16
" Modify: 2017-02-16

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
let s:class = class#old()
let s:class._name_ = 'class#notebook'
let s:class._version_ = 1

" the directory of notebook
let s:class.basedir = ''

" the extention of note file
let s:class.suffix = '.md'

" regexp used
let s:class.pattern = {}
" yyyy/mm/dd
let s:class.pattern.datePath = '^\d\d\d\d/\d\d/\d\d\ze/\?'
let s:class.pattern.dateYear = '^\d\d\d\d\ze/\?'
let s:class.pattern.dateMonth = '^\d\d\d\d/\d\d\ze/\?'
" yyyymmdd
let s:class.pattern.dateInt = '^\d\{8\}'
" yyyymmdd_n- \1=NoteDate, \2=NoteNumber, \3=Private
let s:class.pattern.noteFile = '^\(\d\{8\}\)_\(\d\+\)\(-\?\)'

function! class#notebook#class() abort "{{{
    return s:class
endfunction "}}}

" NEW:
function! class#notebook#new(...) abort "{{{
    let l:obj = copy(s:class)
    call l:obj._new_(a:000)
    return l:obj
endfunction "}}}

" CTOR:
function! class#notebook#ctor(this, argv) abort "{{{
    if len(a:argv) > 0
        call a:this.SetBasedir(a:argv[0])
    endif
endfunction "}}}

" ISOBJECT:
function! class#notebook#isobject(that) abort "{{{
    return s:class._isobject_(a:that)
endfunction "}}}

" SetBasedir: set the directory of notebook, return 0 on success
function! s:class.SetBasedir(pBasedir) dict abort "{{{
    if empty(a:pBasedir)
        echoerr 'cannot set notebook to NONE directory'
        return 1
    endif

    if !isdirectory(a:pBasedir)
        echoerr 'cannot set notebook to directory that not exists: ' . a:pBasedir
        return 2
    endif

    let self.basedir = a:pBasedir
    return 0
endfunction "}}}

" Datedir: 
function! s:class.Datedir() dict abort "{{{
    return self.basedir . '/d'
endfunction "}}}
" Tagdir: 
function! s:class.Tagdir() dict abort "{{{
    return self.basedir . '/t'
endfunction "}}}
" Cachedir: 
function! s:class.Cachedir() dict abort "{{{
    return self.basedir . '/c'
endfunction "}}}

" Notedir: full path of day
" intput: yyyy/mm/dd
function! s:class.Notedir(sDatePath) dict abort "{{{
    if a:sDatePath !~ self.pattern.datePath
        echoerr a:sDatePath . ' is not a valid day path as yyyy/mm/dd'
        return ''
    else
        return self.Datedir() . '/' . a:sDatePath
    endif
endfunction "}}}

" Notefile: full path of a note file, by rule, may not exists yet
" input: (sDatePath, iNumber, [bPrivate])
" return: <notebook>/d/yyyy/mm/dd/yyyymmdd_n[-].md
function! s:class.Notefile(sDatePath, iNumber, ...) dict abort "{{{
    if match(a:sDatePath, self.pattern.datePath) == -1
        echoerr a:sDatePath . ' is not a valid day path as yyyy/mm/dd'
        return ''
    endif

    let l:iDateInt = substitute(a:sDatePath, '/', '', 'g')
    let l:pFileName = self.Datedir() . '/' . a:sDatePath . '/' . l:iDateInt . '_' . a:iNumber

    if a:0 > 0 && a:1
        let l:pFileName .= '-'
    endif

    let l:pFileName .= self.suffix

    return l:pFileName
endfunction "}}}

" GlobNote: glob note file in a date, and optional note number
function! s:class.GlobNote(sDatePath, ...) dict abort "{{{
    let l:pDatedir = self.Datedir()
    if empty(a:sDatePath)
        let l:pDiretory = l:pDatedir
    elseif a:sDatePath =~ self.pattern.dateYear
        let l:pDiretory = l:pDatedir . '/' . a:sDatePath
    else
        :ELOG 'expact date path argument as yyyy[/mm/dd]'
        return []
    endif

    if a:sDatePath =~ self.pattern.datePath
        " full date path
        let l:iDateInt = substitute(a:sDatePath, '/', '', 'g')
        let l:iNumber = get(a:000, 0, '')
        let l:sNoteGlob = printf('%s/%s_%s*%s', l:pDiretory, l:iDateInt, l:iNumber, self.suffix)
    else
        " partial date path, glob recursively
        let l:sNoteGlob = printf('%s/**/*%s', l:pDiretory, self.suffix)
    endif

    let l:lpNoteFile = glob(l:sNoteGlob, 0, 1)
    return l:lpNoteFile
endfunction "}}}

" NoteCount: how many note in a day (yyyy/mm/dd)
function! s:class.NoteCount(sDatePath) dict abort "{{{
    let l:lpNoteFile = self.GlobNote(a:sDatePath)
    let l:iCount = len(l:lpNoteFile)
    return l:iCount
endfunction "}}}

" AllocNewNote: return a full path name used as new note in a day
function! s:class.AllocNewNote(sDatePath, ...) dict abort "{{{
    let l:iCount = self.NoteCount(a:sDatePath)
    let l:iCount += 1
    if a:0 > 0
        let l:bPrivate = a:1
    else
        let l:bPrivate = v:false
    endif
    return self.Notefile(a:sDatePath, l:iCount, l:bPrivate)
endfunction "}}}

" GetLastNote: return full path name of the last note in a day
function! s:class.GetLastNote(sDatePath) dict abort "{{{
    let l:iCount = self.NoteCount(a:sDatePath)
    if l:iCount <= 0
        let l:iCount = 1
    endif
    return self.FindNoteByDateNo(a:sDatePath, l:iCount, 1)
endfunction "}}}

" FindNoteByDateNo: 
" given a date and number, return the note file full path
" the note may or may not be private, that have - suffix
" option: if a:1 nonempty, allow return a nonexists note file name
function! s:class.FindNoteByDateNo(sDatePath, iNumber, ...) abort "{{{
    let l:lpNoteFile = self.GlobNote(a:sDatePath, a:iNumber)
    let l:iCount = len(l:lpNoteFile)

    if l:iCount == 1
        return l:lpNoteFile[0]
    elseif l:iCount > 1
        echo 'have more than one note, something wrong:'
        for l:pNoteFile in l:lpNoteFile
            echo l:pNoteFile
        endfor
        return ''
    elseif l:iCount == 0
        if a:0 > 0 && !empty(a:1)
            return self.Notefile(a:sDatePath, a:iNumber)
        else
            return ''
        endif
    endif

    return ''
endfunction "}}}

" LOAD:
let s:load = 1
echo 'class#notebook is loading ...'
function! class#notebook#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1) && exists('s:load')
        unlet s:load
        return 0
    endif
    return s:load
endfunction "}}}

" TEST:
function! class#notebook#test(...) abort "{{{
    echo 'notebook in ~/notebook'
    " let l:jNoteBook = class#notebook#new('~/notebook')
    let l:jNoteBook = class#notebook#new(expand('~/notebook'))
    " echo l:jNoteBook.Notedir('2010/1/11')
    echo l:jNoteBook.Notedir('2010/01/11')
    echo l:jNoteBook.Notedir('2010/11/11')
    echo l:jNoteBook.Notefile('2010/11/11', 1)
    echo l:jNoteBook.Notefile('2010/11/11', 2, 'private')
    echo l:jNoteBook.Notefile('2010/11/11', 3, 1)
    echo l:jNoteBook.Notefile('2010/11/11', 4, 0)

    echo 'change notebook in ~/notebook-test'
    " call l:jNoteBook.SetBasedir('~/notebook-test')
    call l:jNoteBook.SetBasedir(expand('~/notebook-test'))
    echo l:jNoteBook.Notedir('2010/01/11')
    echo l:jNoteBook.Notedir('2010/11/11')
    echo l:jNoteBook.Notefile('2010/11/11', 1)
    echo l:jNoteBook.Notefile('2010/11/11', 2, 'private')
    echo l:jNoteBook.Notefile('2010/11/11', 3, 1)
    echo l:jNoteBook.Notefile('2010/11/11', 4, 0)
    return 0
endfunction "}}}
