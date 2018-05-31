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

" OnSave: save current editing note buffer
function! vnote#perlx#OnSave(sNoteID) abort "{{{
    let l:pScript = s:rtp.AddPath(s:perlx, 'save.pl')
    if !filereadable(l:pScript)
        reutrn -1
    endif
    let l:aCmd = ['perl', l:pScript, a:sNoteID]
    let l:opt = {'close_cb': function('s:cbSave'), 
                \'in_io': 'buffer', 'in_name': '%', 
                \'in_top': 1, 'in_bot': 2
                \}
    let l:job = job_start(l:aCmd, l:opt)
endfunction "}}}

" cbSave: 
function! s:cbSave(channel) abort "{{{
    echomsg 'vnote#perlx#OnSave() done!'
    " call s:jNoteTab.OnUpdate()
    while ch_status(a:channel, {'part': 'out'}) == 'buffered'
        let l:msg = ch_read(a:channel)
        echomsg l:msg
        if l:msg =~? 'success'
            call s:jNoteTab.OnUpdate()
        endif
    endwhile
endfunction "}}}

" OnBuild: 
function! vnote#perlx#OnBuild() abort "{{{
    let l:pScript = s:rtp.AddPath(s:perlx, 'build.pl')
    if !filereadable(l:pScript)
        reutrn -1
    endif
    let l:aCmd = ['perl', l:pScript, s:jNoteBook.basedir]
    let l:job = job_start(l:aCmd, {'close_cb': function('s:cbBuild')})
endfunction "}}}

" cbBuild: 
function! s:cbBuild(channel) abort "{{{
    echomsg 'vnote#perlx#OnUpdate() done!'
    while ch_status(a:channel, {'part': 'out'}) == 'buffered'
        let l:msg = ch_read(a:channel)
        echomsg l:msg
        if l:msg =~? 'success'
            call s:jNoteTab.OnUpdate()
        endif
    endwhile
endfunction "}}}

" OnUpdate: 
function! vnote#perlx#OnUpdate() abort "{{{
    let l:pScript = s:rtp.AddPath(s:perlx, 'update.pl')
    if !filereadable(l:pScript)
        reutrn -1
    endif
    let l:aCmd = ['perl', l:pScript, s:jNoteBook.basedir]
    let l:job = job_start(l:aCmd, {'close_cb': function('s:cbUpdate')})
endfunction "}}}

" cbUpdate: 
function! s:cbUpdate(channel) abort "{{{
    echomsg 'vnote#perlx#OnUpdate() done!'
    " call s:jNoteTab.OnUpdate()
    while ch_status(a:channel, {'part': 'out'}) == 'buffered'
        let l:msg = ch_read(a:channel)
        echomsg l:msg
        if l:msg =~? 'success'
            call s:jNoteTab.OnUpdate()
        endif
    endwhile
endfunction "}}}
