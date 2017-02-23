" File: notelist
" Author: lymslive
" Description: unite source for notelist
" Create: 2017-02-21
" Modify: 2017-02-21

" define: 
function! unite#sources#notelist#define() abort "{{{
    return s:source
endfunction "}}}

let s:source = {
    \ 'name' : 'notelist',
    \ 'description' : 'candidates from filelist',
    \ 'default_kind' : 'file',
    \ }

function! s:source.gather_candidates(args, context) abort "{{{
    let l:args = unite#helper#parse_source_args(a:args)

    if empty(args)
        let l:args = []
    endif

    let l:jNoteBook = vnote#GetNoteBook()
    let l:jNoteList = class#notelist#new(l:jNoteBook)
    let l:lsContent = l:jNoteList.GatherContent(l:args)

    let candidates = []
    for l:sEntry in l:lsContent
        let l:dCand = {'word' : l:sEntry}

        let l:jNoteEntry = class#notename#new(l:sEntry)
        if empty(l:jNoteEntry.string())
            continue
        endif

        let l:pFileName = l:jNoteEntry.GetFullPath(l:jNoteBook)
        let l:dCand['action__path'] = l:pFileName

        call add(candidates, l:dCand)
    endfor

    if empty(candidates)
        let l:dCand = {'word' : '<!-- empty notelist -->', 'action__path' : '', 'is_dummy': 1}
        call add(candidates, l:dCand)
    endif

    return candidates
endfunction "}}}

function! s:source.complete(args, context, arglead, cmdline, cursorpos) abort "{{{
    return notelist#CompleteList(a:arglead, a:cmdline, a:cursorpos)
endfunction"}}}
