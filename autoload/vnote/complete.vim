" File: complete.vim
" Author: yourname
" Description: complete for vnote custome command
" Create: 2017-02-25
" Modify: 2017-02-25

" NoteList: 
function! vnote#complete#NoteList(ArgLead, CmdLine, CursorPos) abort "{{{
    let l:jNoteBook = vnote#GetNoteBook()

    if empty(a:ArgLead) || match(a:ArgLead, '^\d\d') == -1
        " compelete tag
        let l:tag_dir = l:jNoteBook.Tagdir()
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
            let l:day_dir = l:jNoteBook.Datedir()
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

" NoteConfig: 
function! vnote#complete#NoteConfig(ArgLead, CmdLine, CursorPos) abort "{{{
    let l:dConfig = vnote#GetConfig()
    return filter(keys(l:dConfig), 'v:val =~ "^" . a:ArgLead')
endfunction "}}}
