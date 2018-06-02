" Class: class#notebar
" Author: lymslive
" Description: VimL class frame
" Create: 2018-05-22
" Modify: 2018-05-22

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
let s:class = class#old()
let s:class._name_ = 'class#notebar'
let s:class._version_ = 1

let s:class.notebook = {}

let s:class.taglist = []
let s:class.tagsort = 1
let s:class.tagtime = 0
let s:TAG_SORT_BY_NAME = 1
let s:TAG_SORT_BY_NUMW = 2

function! class#notebar#class() abort "{{{
    return s:class
endfunction "}}}

" NEW:
function! class#notebar#new(...) abort "{{{
    let l:obj = class#new(s:class, a:000)
    return l:obj
endfunction "}}}
" CTOR:
function! class#notebar#ctor(this, ...) abort "{{{
    if a:0 > 0 && class#notebook#isobject(a:1)
        let a:this.notebook = a:1
    else
        echoerr 'expect a class#notebook to construct a class#notebar object'
    endif
endfunction "}}}

" ISOBJECT:
function! class#notebar#isobject(that) abort "{{{
    return class#isobject(s:class, a:that)
endfunction "}}}

" RefreshBar: 
function! s:class.RefreshBar() dict abort "{{{
    let l:lsContent = self.GatherContent()
    if expand('%:p') !=# self.notebook.GetBarName()
        execute 'edit ' . self.notebook.GetBarName()
    endif

    setlocal modifiable
    :1,$delet
    " call append(0, l:lsContent)
    call setline(1, l:lsContent)
    if &filetype !=# 'notebar'
        setlocal filetype=notebar
        setlocal buftype=nofile
        setlocal bufhidden=hide
        setlocal noswapfile
        setlocal nobuflisted
        setlocal nowrap
    endif
    setlocal nomodifiable
endfunction "}}}

" GatherContent: 
function! s:class.GatherContent() dict abort "{{{
    let l:lsContent = []
    call add(l:lsContent, '- mark')
    call add(l:lsContent, '  mru')
    call add(l:lsContent, '+ date')
    call add(l:lsContent, '- tag')

    let l:pTagdb = self.notebook.GetTagdbFile()
    if filereadable(l:pTagdb)
        let self.taglist = readfile(l:pTagdb)
        let self.tagtime = getftime(l:pTagdb)
        let self.tagsort = s:TAG_SORT_BY_NAME
        let l:lsTag = map(copy(self.taglist), function('s:tag_entry'))
        call extend(l:lsContent, l:lsTag)
    endif

    return l:lsContent
endfunction "}}}

" tag_entry: convert tag entry from tag.db file
function! s:tag_entry(key, val) abort "{{{
    let l:lsField = split(a:val, "\t")
    if len(l:lsField) < 3
        :ELOG 'unexpect format of tag.db file'
        return ''
    endif
    let l:sEntry = printf('  %s [%d]', l:lsField[0], l:lsField[1])
    return l:sEntry
endfunction "}}}

" GetCursorArg: return a string list that can be as argument for :NoteList
" '-t tagname' or '-d datepath' or '-m mark'
" according cursor
function! s:class.GetCursorArg() dict abort "{{{
    let l:sLine = getline('.')
    if l:sLine =~? '^[-+]'
        :ELOG 'please select any entry under this section'
        return 0
    endif

    let l:iSection = search('^[-+]', 'nb')
    if l:iSection <= 0
        :ELOG 'cannot determin the section, maybe invalid buffer'
        return -1
    endif

    let l:sSecLine = getline(l:iSection) 
    let l:sSecType = matchstr(l:sSecLine, '^[-+] \zs[mdt]\ze')
    if empty(l:sSecType)
        :ELOG 'unknow section: ' . l:sSecLine
        return -1
    endif

    let l:sSubName = matchstr(l:sLine, '^\s*\zs\S\+\ze')
    if empty(l:sSubName)
        :ELOG 'cannot find valid subname: ' . l:sLine
        return -1
    endif

    if l:sSecType == 'd' && l:sSubName !~ '\d\+\/\d\+'
        :DLOG 'a year maybe too many notes, press o to refine'
        return -1
    endif

    return ['-' . l:sSecType, l:sSubName]
endfunction "}}}

" OnCheckTime: 
" when tag.db updated outside vim, refresh tag section of notebar
function! s:class.OnCheckTime() dict abort "{{{
    let l:pTagdb = self.notebook.GetTagdbFile()
    if !filereadable(l:pTagdb)
        return
    endif
    let l:tCurrent = getftime(l:pTagdb)
    if l:tCurrent <= self.tagtime
        return
    endif

    let self.taglist = readfile(l:pTagdb)
    let self.tagtime = getftime(l:pTagdb)
    if self.tagsort == s:TAG_SORT_BY_NUMW
        call sort(self.taglist, function('s:tag_weigh_sorter'))
    endif 
    let l:lsTag = map(copy(self.taglist), function('s:tag_entry'))
    call s:redraw_taglist(l:lsTag)
endfunction "}}}

" SortTag: switch sort type for tag section, when cursor on it
" default sort by tag name
" alterably sort by weith with number and time
function! s:class.SortTag() dict abort "{{{
    if self.tagsort == s:TAG_SORT_BY_NAME
        call sort(self.taglist, function('s:tag_weigh_sorter'))
        let self.tagsort = s:TAG_SORT_BY_NUMW
    else
        call sort(self.taglist)
        let self.tagsort = s:TAG_SORT_BY_NAME
    endif

    let l:lsTag = map(copy(self.taglist), function('s:tag_entry'))
    call s:redraw_taglist(l:lsTag)
endfunction "}}}

" redraw_taglist: 
function! s:redraw_taglist(lsTag) abort "{{{
    let l:iSection = search('^[-+] tag', 'bw')
    if l:iSection <= 0
        return 0
    endif
    setlocal modifiable
    execute (l:iSection + 1) . ',$delete'
    call append('$', a:lsTag)
    setlocal nomodifiable
endfunction "}}}

" tag_weigh_sorter: 
" each note having this tag weight 1
" the tag modified today weight 7, decreasing 6 5 ... 0
" see also s:max_day_weight
function! s:tag_weigh_sorter(first, second) abort "{{{
    let l:lsFirst = split(a:first, "\t")
    let l:lsSecond = split(a:second, "\t")
    if len(l:lsFirst) < 3 || len(l:lsSecond) < 3
        :ELOG 'unexpect format of tag entry'
        return 0
    endif

    let l:wFirst = l:lsFirst[1] + s:time_weight(l:lsFirst[2])
    let l:wSecond = l:lsSecond[1] + s:time_weight(l:lsSecond[2])

    " sort from more weight to less weight
    return -(l:wFirst - l:wSecond)
endfunction "}}}

" time_weight: 
let s:max_day_weight = 7
function! s:time_weight(time) abort "{{{
    let l:tDiff = a:time - localtime()
    let l:dDiff = l:tDiff / (3600 * 24)
    let l:iWeight = s:max_day_weight + l:dDiff
    if l:iWeight > s:max_day_weight
        let l:iWeight = s:max_day_weight
    elseif l:iWeight < 0
        let l:iWeight = 0
    endif
    return l:iWeight
endfunction "}}}

" OpenCloseDate: 
function! s:class.OpenCloseDate() dict abort "{{{
    let l:iLine = line('.')
    let l:sLine = getline('.')
    let l:iLineTag = search('^[-+] tag', 'n')
    if l:iLineTag <= 0 || l:iLine >= l:iLineTag
        :ELOG 'not in date section'
        return
    endif

    if l:sLine =~? '^+ date'
        " open + date
        let l:jYear = class#notebrowse#date#new(self.notebook, '')
        let l:lsYear = map(l:jYear.list(), '"  " . v:val . "/"')
        let l:lsYear = filter(l:lsYear, 'v:val !~? "date"')
        setlocal modifiable
        call setline('.', '- date')
        call append('.', l:lsYear)
        setlocal nomodifiable

    elseif l:sLine =~? '^- date'
        " close - date
        setlocal modifiable
        call setline('.', '+ date')
        if l:iLineTag - 1 > l:iLine + 1
            let l:cmd = printf('%d,%d delete', l:iLine+1, l:iLineTag-1)
            execute l:cmd
            :normal! k
        endif
        setlocal nomodifiable

    elseif l:sLine =~? '^\s\+\d\+' && l:sLine =~? '/$'
        " open sub datepath
        let l:daylead = substitute(l:sLine, '^\s\+', '', '')
        let l:daylead = substitute(l:daylead, '/$', '', '')
        let l:jDate = class#notebrowse#date#new(self.notebook, l:daylead)
        if l:daylead =~? '\d\+\/\d\+'
            let l:lsDate = map(l:jDate.list(), '"  " . v:val')
        else
            let l:lsDate = map(l:jDate.list(), '"  " . v:val . "/"')
        endif
        setlocal modifiable
        call setline('.', '  ' . l:daylead)
        call append('.', l:lsDate)
        setlocal nomodifiable

    elseif l:sLine =~? '^\s\+\d\+' && l:sLine !~? '/$'
        " close sub datepath
        if l:sLine =~? '\d\+\/\d\+\/\d\+'
            let l:sMonth = matchstr(l:sLine, '\d\+\/\d\+\ze\/\d\+')
            let l:iMonth = search(l:sMonth . '$', 'b')
            if l:iMonth > 0
                call self.OpenCloseDate()
            endif
        else
            let l:iFirst = l:iLine + 1
            let l:iLast = l:iLine
            while l:iLast + 1 < l:iLineTag
                if getline(l:iLast + 1) =~? l:sLine
                    let l:iLast += 1
                else
                    break
                endif
            endwhile
            setlocal modifiable
            call setline('.', l:sLine . '/')
            if l:iLast >= l:iFirst
                let l:cmd = printf('%d,%d delete', l:iFirst, l:iLast)
                execute l:cmd
                :normal! k
            endif
            setlocal nomodifiable
        end
    endif
endfunction "}}}

" LOAD:
let s:load = 1
function! class#notebar#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1)
        unlet! s:load
    endif
endfunction "}}}

" TEST:
function! class#notebar#test(...) abort "{{{
    let l:obj = class#notebar#new()
    call class#echo(l:obj)
endfunction "}}}
