" Class: class#notetag#mru
" Author: lymslive
" Description: VimL class frame
" Create: 2017-03-14
" Modify: 2017-03-15

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
let s:class = class#notetag#old()
let s:class._name_ = 'class#notetag#mru'
let s:class._version_ = 1

let s:class.queue = {}

function! class#notetag#mru#class() abort "{{{
    return s:class
endfunction "}}}

" NEW:
function! class#notetag#mru#new(...) abort "{{{
    let l:obj = copy(s:class)
    call l:obj._new_(a:000)
    return l:obj
endfunction "}}}

" CTOR: argv = [capacity] auto load mru.tag if readable
function! class#notetag#mru#ctor(this, argv) abort "{{{
    let l:Suctor = s:class._suctor_()
    call l:Suctor(a:this, ['mru'])

    let l:iCapacity = get(a:argv, 0, 10)
    let a:this.queue = class#requeue#new(l:iCapacity)

    let l:pTagFile = a:this.GetTagFile()
    if filereadable(l:pTagFile)
        call a:this.queue.Fill(readfile(l:pTagFile), 1)
    endif
endfunction "}}}

" ISOBJECT:
function! class#notetag#mru#isobject(that) abort "{{{
    return s:class._isobject_(a:that)
endfunction "}}}

" GetTagFile: 
function! s:class.GetTagFile() dict abort "{{{
    let l:rtp = module#less#rtp#import()
    return self.notebook.Markdir() . l:rtp.separator . self.tag . '.tag'
endfunction "}}}

" SaveTagFile: 
function! s:class.SaveTagFile() dict abort "{{{
    return self.Write(self.list())
endfunction "}}}

" Resize: 
function! s:class.Resize(iCapacity) dict abort "{{{
    return self.queue.Resize(a:iCapacity)
endfunction "}}}

" AddEntry: 
function! s:class.AddEntry(sNoteEntry) dict abort "{{{
    return self.queue.Add(a:sNoteEntry)
endfunction "}}}

" list: 
function! s:class.list() dict abort "{{{
    return self.queue.list()
endfunction "}}}

" LOAD:
let s:load = 1
:DLOG '-1 class#notetag#mru is loading ...'
function! class#notetag#mru#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1) && exists('s:load')
        unlet s:load
        return 0
    endif
    return s:load
endfunction "}}}

" TEST:
function! class#notetag#mru#test(...) abort "{{{
    return 0
endfunction "}}}
