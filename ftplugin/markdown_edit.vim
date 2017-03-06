" File: markdown_edit
" Author: lymslive
" Description: ftplugin for markdown files
" Create: 2017-02-27
" Modify: 2017-03-05

:PLUGINLOCAL

" abbreviate <buffer> todo: - [todo]
abbreviate <buffer> <expr> todo: edit#markdown#hTodo_i()
abbreviate <buffer> <expr> -t edit#markdown#hTodo_i()
command! -buffer -nargs=* TODO call edit#markdown#hTodo(<f-args>)

" handle <CR> map
nnoremap <buffer> <expr> <CR> edit#markdown#hEnterExpr()
inoremap <buffer> <expr> <CR> edit#markdown#hEnterExpr_i()

:PLUGINAFTER
