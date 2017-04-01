" File: markdown
" Author: lymslive
" Description: editing tools for ftplugin/markdown
" Create: 2017-02-27
" Modify: 2017-02-27

let s:pattern = {}
let s:pattern.todo = '^[-+*]\s\+\[todo\(:\d\+%\?\)\?\]'
let s:pattern.empty_ulist = '^\s*[-+*]\?\s*$'
let s:pattern.ulist = '^\s*[-+*]\s\+'
let s:pattern.olist = '^\s*\zs\d\+\ze\.\s\+'

" Todo: modify todo item
function! edit#markdown#hTodo(...) abort "{{{
    let l:iProgress = 0
    let l:sText = ''

    if a:0 > 2
        let l:iProgress = 0 + a:1
        let l:sText = a:2
    elseif a:0 == 1
        if a:1 =~ '^\d'
            let l:iProgress = 0 + a:1
        else
            let l:sText = a:1
        endif
    endif

    let l:sLine = getline('.')
    " modify current todo's progress
    let l:sTodoPattern = s:pattern.todo
    if l:sLine =~ l:sTodoPattern
        if l:iProgress >= 100
            let l:sTodoLabel = printf('+ [todo:%d%%]', 100)
            let l:sLine = substitute(l:sLine, l:sTodoPattern, l:sTodoLabel, '')
        elseif l:iProgress > 0
            let l:sTodoLabel = printf('* [todo:%d%%]', l:iProgress)
            let l:sLine = substitute(l:sLine, l:sTodoPattern, l:sTodoLabel, '')
        else
            let l:sTodoLabel = '- [todo]'
            let l:sLine = substitute(l:sLine, l:sTodoPattern, l:sTodoLabel, '')
        endif
        call setline('.', l:sLine)
        normal! $
        return 0
    endif

    " add new todo item
    let l:sInsert = '- [todo]'
    if !empty(l:sText)
        let l:sInsert .= l:sText
    endif

    if l:sLine =~ s:pattern.empty_ulist
        let l:bReplace = class#TRUE
        call setline('.', l:sInsert)
        normal! $
    else
        let l:bReplace = class#FALSE
        call append('.', l:sInsert)
        normal! j$
    endif

endfunction "}}}

" Todo_i: 
function! edit#markdown#hTodo_i() abort "{{{
    let l:sCmd = "\<ESC>:TODO\<CR>a"
    return l:sCmd
endfunction "}}}

" EnterNormal: for nmap <expr> <CR>
function! edit#markdown#hEnterExpr() abort "{{{
    let l:sTodoPattern = s:pattern.todo
    let l:sLine = getline('.')
    if l:sLine =~ s:pattern.todo
        return ':TODO '
    else
        return ':Note'
    endif
endfunction "}}}

" EnterNormal_i: for imap <expr> <CR>
" a:1 only response at end of line
function! edit#markdown#hEnterExpr_i(...) abort "{{{
    let l:sLine = getline('.')

    if a:0 > 0 && !empty(a:1)
        if col('.') <= len(l:sLine)
            return "\<CR>"
        endif
    endif

    if l:sLine =~ s:pattern.todo
        return "\<CR>- [todo] "
    elseif l:sLine =~ s:pattern.ulist
        return "\<CR>" . matchstr(l:sLine, s:pattern.ulist)
    elseif l:sLine =~ s:pattern.olist
        let l:iNumber = matchstr(l:sLine, s:pattern.olist)
        let l:iNumber += 1
        return "\<CR>" . l:iNumber . '. '
    else
        return "\<CR>"
    endif
endfunction "}}}

