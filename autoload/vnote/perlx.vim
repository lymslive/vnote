" File: perlx
" Author: lymslive
" Description: call perl script to do hard work
" Create: 2018-05-29
" Modify: 2018-05-29

let s:perlx = vnote#GetConfig('perlx_script_dir')
let g:vnote#perlx#enable = 1
if empty(s:perlx) || !executable('perl') || !has('job')
    let g:vnote#perlx#enable = 0
    finish
endif

let s:jNoteBook = vnote#GetNoteBook()
let s:jNoteTab = vnote#GetNoteTab()
let s:rtp = class#less#rtp#export()

" OnSave: 
function! vnote#perlx#OnSave(pNote) abort "{{{
    let l:pScript = s:rtp.AddPath(s:perlx, 'save.pl')
    if !filereadable(l:pScript)
        reutrn -1
    endif
    let l:aCmd = ['perl', l:pScript, a:pNote]
    let l:job = job_start(l:aCmd, {'close_cb': function('s:cbSave')})
endfunction "}}}

" cbSave: 
function! s:cbSave(channel) abort "{{{
    echomsg 'vnote#perlx#OnSave() done!'
    call s:jNoteTab.OnUpdate()
endfunction "}}}

" OnBuild: 
function! vnote#perlx#OnBuild() abort "{{{
    let l:pScript = s:rtp.AddPath(s:perlx, 'build.pl')
    if !filereadable(l:pScript)
        reutrn -1
    endif
    let l:aCmd = ['perl', l:pScript, s:jNoteBook.basedir, 'create']
    let l:job = job_start(l:aCmd, {'close_cb': function('s:cbBuild')})
endfunction "}}}

" cbBuild: 
function! s:cbBuild(channel) abort "{{{
    echomsg 'vnote#perlx#OnUpdate() done!'
    call s:jNoteTab.OnUpdate()
endfunction "}}}

" OnUpdate: 
function! vnote#perlx#OnUpdate() abort "{{{
    let l:pScript = s:rtp.AddPath(s:perlx, 'update.pl')
    if !filereadable(l:pScript)
        reutrn -1
    endif
    let l:aCmd = ['perl', l:pScript, s:jNoteBook.basedir, 'update']
    let l:job = job_start(l:aCmd, {'close_cb': function('s:cbUpdate')})
    " code
endfunction "}}}

" cbUpdate: 
function! s:cbUpdate(channel) abort "{{{
    echomsg 'vnote#perlx#OnUpdate() done!'
    call s:jNoteTab.OnUpdate()
endfunction "}}}
