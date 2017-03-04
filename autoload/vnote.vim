" File: vnote
" Author: lymslive
" Description: manage the overall vnote plugin
" Create: 2017-02-17
" Modify: 2017-02-24

let s:default_notebook = "~/notebook"
if exists('g:vnote_default_notebook')
    let s:default_notebook = g:vnote_default_notebook
endif
let s:default_notebook = expand(s:default_notebook)

" global configue for vnote
let s:dConfig = {}
let s:dConfig.note_file_head_line = 10
let s:dConfig.note_file_max_tags = 5
let s:dConfig.auto_add_minus_tag = v:true
let s:dConfig.auto_add_plus_tag = v:true
" let s:dConfig.rename_by_tag = v:false

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
function! vnote#SetConfig(...) abort "{{{
    if a:0 == 0
        :ELOG '[vnote] SetConfig need argument paris'
        return -1
    elseif a:0 % 2 != 0
        :ELOG '[vnote] SetConfig need argument paris'
        return -1
    endif

    let l:dict = module#less#dict#import()
    let l:dArg = l:dict.FromList(a:000)

    let l:math = module#less#math#import() 
    if has_key(l:dArg, 'note_file_head_line')
        let l:dArg['note_file_head_line'] = l:math.LimitBetween(l:dArg['note_file_head_line'], 2, 20)
    endif
    if has_key(l:dArg, 'note_file_max_tags')
        let l:dArg['note_file_max_tags'] = l:math.LimitBetween(l:dArg['note_file_max_tags'], 2, 10)
    endif

    call l:dict.Absorb(s:dConfig, l:dArg)

    return 0
endfunction "}}}

" NoteConfig: 
function! vnote#hNoteConfig(...) abort "{{{
    if a:0 == 0
        :LOG '[vnote] current config:'
        let l:dict = module#less#dict#import()
        echo l:dict.Display(s:dConfig)
        return 0
    endif

    let l:sArg = join(a:000, "\t")
    let l:lsArgv = split(l:sArg, '[\s,=;:]\+')
    return vnote#SetConfig(l:lsArgv)
endfunction "}}}

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

