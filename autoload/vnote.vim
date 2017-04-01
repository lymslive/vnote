" File: vnote
" Author: lymslive
" Description: manage the overall vnote plugin
" Create: 2017-02-17
" Modify: 2017-03-20

let s:default_notebook = "~/notebook"
if exists('g:vnote_default_notebook')
    let s:default_notebook = g:vnote_default_notebook
endif
let s:default_notebook = expand(s:default_notebook)

" global configue for vnote
let s:dConfig = {}
let s:dConfig.note_file_head_line = 10
let s:dConfig.note_file_max_tags = 5

" for public and private tag label
let s:dConfig.auto_add_minus_tag = g:class#TRUE
let s:dConfig.auto_add_plus_tag = g:class#TRUE
let s:dConfig.auto_save_minus_tag = g:class#FALSE
let s:dConfig.auto_save_plus_tag = g:class#FALSE

" put cursor in which entry default: 1, 2, .. '$'
let s:dConfig.list_default_cursor = '$'

let s:dConfig.max_mru_note_list = 10

" GetNoteBook: 
let s:jNoteBook = {}
function! vnote#GetNoteBook() "{{{
    if empty(s:jNoteBook)
        let s:jNoteBook = class#notebook#new(s:default_notebook)
    endif
    return s:jNoteBook
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

    let l:dict = module#less#dict#import()
    let l:dArg = l:dict.FromList(a:lsArgv)

    let l:math = module#less#math#import() 
    if has_key(l:dArg, 'note_file_head_line')
        let l:dArg['note_file_head_line'] = l:math.LimitBetween(l:dArg['note_file_head_line'], 2, 20)
    endif
    if has_key(l:dArg, 'note_file_max_tags')
        let l:dArg['note_file_max_tags'] = l:math.LimitBetween(l:dArg['note_file_max_tags'], 2, 10)
    endif
    if has_key(l:dArg, 'max_mru_note_list')
        let l:dArg['max_mru_note_list'] = l:math.LimitBetween(l:dArg['max_mru_note_list'], 3, 50)
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
        let l:dict = module#less#dict#import()
        echo l:dict.Display(s:dConfig, '  ', 1)
        return 0
    endif

    let l:sArg = join(a:000, "\t")
    let l:lsArgv = split(l:sArg, '[\t ,=;:]\+')
    return vnote#SetConfig(l:lsArgv)
endfunction "}}}

" load remaps
call vnote#remap#load()

" statistics infor
let s:dStatis = {}
let s:dStatis.lister = 0
" GetStatis: 
function! vnote#GetStatis() abort "{{{
    return s:dStatis
endfunction "}}}

" FindWindow: find and jump between notelist window and note(markdown) window
function! vnote#FindListWindow() abort "{{{
    let l:window = module#less#window#import()
    return l:window.FindWindow('notelist')
endfunction "}}}
function! vnote#GotoListWindow() abort "{{{
    let l:window = module#less#window#import()
    return l:window.GotoWindow('notelist')
endfunction "}}}
function! vnote#FindNoteWindow() abort "{{{
    let l:window = module#less#window#import()
    return l:window.FindWindow('markdown')
endfunction "}}}
function! vnote#GotoNoteWindow() abort "{{{
    let l:window = module#less#window#import()
    return l:window.GotoWindow('markdown')
endfunction "}}}

" OnVimLeave: 
function! vnote#OnVimLeave() abort "{{{
    let l:jNoteBook = vnote#GetNoteBook()
    call l:jNoteBook.SaveMru()
    call garbagecollect()
endfunction "}}}
