" File: vnote
" Author: lymslive
" Description: manage the overall vnote plugin
" Create: 2017-02-17
" Modify: 2018-05-27

let g:vnote#version = 0.60

let s:default_notebook = "$HOME/notebook"
if exists('g:vnote_default_notebook')
    let s:default_notebook = g:vnote_default_notebook
endif
let s:default_notebook = resolve(expand(s:default_notebook))

" global configue for vnote
let s:dConfig = {}
let s:dConfig.note_file_head_line = 2
let s:dConfig.note_file_max_tags = 5

" for public and private tag label
let s:dConfig.auto_add_minus_tag = v:true
let s:dConfig.auto_add_plus_tag = v:true
let s:dConfig.auto_save_minus_tag = v:false
let s:dConfig.auto_save_plus_tag = v:false

" put cursor in which entry default: 1, 2, .. '$'
let s:dConfig.list_default_cursor = '$'

let s:dConfig.max_mru_note_list = 20

let s:dConfig.perlx_script_dir = ''

" GetNoteBook: 
let s:jNoteBook = {}
function! vnote#GetNoteBook() "{{{
    if empty(s:jNoteBook)
        let s:jNoteBook = class#notebook#new(s:default_notebook)
    endif
    return s:jNoteBook
endfunction "}}}

" GetNoteTab: 
let s:jNoteTab = {}
function! vnote#GetNoteTab() abort "{{{
    if empty(s:jNoteTab)
        let s:jNoteTab = class#notetab#new(vnote#GetNoteBook())
    endif
    return s:jNoteTab
endfunction "}}}

" GetConfig: 
function! vnote#GetConfig(...) abort "{{{
    if a:0 == 0
        return s:dConfig
    elseif a:0 == 1
        return get(s:dConfig, a:1, '')
    else
        return map(a:000, 'get(s:dConfig, v:val, "")')
    endif
endfunction "}}}

" SetConfig: 
function! vnote#SetConfig(lsArgv) abort "{{{
    if empty(a:lsArgv)
        :ELOG '[vnote] SetConfig need argument in a list'
        return -1
    elseif len(a:lsArgv) % 2 != 0
        :ELOG '[vnote] SetConfig need list of argument with paris'
        return -1
    endif

    let l:dict = class#less#dict#export()
    let l:dArg = l:dict.FromList(a:lsArgv)

    let l:math = class#less#math#export() 
    if has_key(l:dArg, 'note_file_head_line')
        let l:dArg['note_file_head_line'] = l:math.CutEnd(l:dArg['note_file_head_line'], 2, 20)
    endif
    if has_key(l:dArg, 'note_file_max_tags')
        let l:dArg['note_file_max_tags'] = l:math.CutEnd(l:dArg['note_file_max_tags'], 2, 10)
    endif
    if has_key(l:dArg, 'max_mru_note_list')
        let l:dArg['max_mru_note_list'] = l:math.CutEnd(l:dArg['max_mru_note_list'], 3, 50)
    endif

    call l:dict.Absorb(s:dConfig, l:dArg)

    let l:jNoteBook = vnote#GetNoteBook()
    call l:jNoteBook.OnConfigChange(l:dArg)

    return 0
endfunction "}}}

" NoteConfig: 
function! vnote#hNoteConfig(...) abort "{{{
    if a:0 == 0
        :LOG '[vnote] current config:'
        let l:dict = class#less#dict#export()
        echo l:dict.Display(s:dConfig, '  ', 1)
        return 0
    endif

    let l:sArg = join(a:000, "\t")
    let l:lsArgv = split(l:sArg, '[\t ,=;:]\+')
    return vnote#SetConfig(l:lsArgv)
endfunction "}}}

" Remap:
call vnote#remap#load()

" statistics infor
let s:dStatis = {}
let s:dStatis.lister = 0
" GetStatis: 
function! vnote#GetStatis() abort "{{{
    return s:dStatis
endfunction "}}}

" FindWindow: find and jump between windows
let s:window = class#less#window#export()
function! vnote#GotoListWindow() abort "{{{
    return s:window.GotoWindow('notelist')
endfunction "}}}
function! vnote#GotoNoteWindow() abort "{{{
    return s:window.GotoWindow('markdown')
endfunction "}}}
function! vnote#GotoBarWindow() abort "{{{
    return s:window.GotoWindow('notebar')
endfunction "}}}

" find_perlx: 
let s:thisplug = fnamemodify(expand("<sfile>"), ":p:h:h")
let s:rtp = class#less#rtp#export()
function! s:find_perlx() abort "{{{
    if !executable('perl') || !has('job')
        return -1
    endif

    let l:script = 'notedb.pl'

    " 1. ~/notebook/x
    let l:path = s:rtp.AddPath(s:default_notebook, 'x')
    if filereadable(s:rtp.AddPath(l:path, l:script))
        let s:dConfig.perlx_script_dir = l:path
        return
    endif

    " 2. <plugin>vnote/perlx
    let l:path = s:rtp.AddPath(s:thisplug, 'perlx')
    if filereadable(s:rtp.AddPath(l:path, l:script))
        let s:dConfig.perlx_script_dir = l:path
        return
    endif

    return -1
endfunction "}}}
call s:find_perlx()

" GetBlankBar: 
function! vnote#GetBlankBar() abort "{{{
    return s:rtp.AddPath(s:thisplug, 'docs', 'blank.notebar')
endfunction "}}}
" GetBlankList: 
function! vnote#GetBlankList() abort "{{{
    return s:rtp.AddPath(s:thisplug, 'docs', 'blank.notelist')
endfunction "}}}
" GetBlankNote: 
function! vnote#GetBlankNote() abort "{{{
    return s:rtp.AddPath(s:thisplug, 'docs', 'blank-note.md')
endfunction "}}}
" GetHelpDoc: 
function! vnote#GetHelpDoc(lang) abort "{{{
    return s:rtp.AddPath(s:thisplug, 'docs', 'help.' . a:lang)
endfunction "}}}

" OnVimLeave: 
function! vnote#OnVimLeave() abort "{{{
    let l:jNoteBook = vnote#GetNoteBook()
    call l:jNoteBook.SaveMru()
    call garbagecollect()
endfunction "}}}
