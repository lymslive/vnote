# vnote: a note/diary manage plugin in vim
`vnote` `git/readme`

A __chinese version__ readme is also availabe
([一份中文的说明文档也是可利用的](readme-zh.md)).

## Introduction

* note is a markdown plain text file. while note public, diary private.
* notebook is a directory to orginaze many note files in a way.
* vnote is a plugin to edit note and manage notebook, almost in vim.

## Install

### Minimum Requirment:
* OS: linux (windows not test now)
* vim version: 7.4
* Unite.vim plugin: (optional)

### Dependent:
* vimloo: https://github.com/lymslive/vimloo

### Manually Install:

```
$ git clone https://github.com/lymslive/vimloo.git
$ git clone https://github.com/lymslive/vnote.git
: set rtp+=right/path/to/vimloo
: set rtp+=right/path/to/vnote
: cd right/path/to/vnote/doc
: helptags .
```

The `$` lines is shell command, `:` lines is vim ex command.
The "set rtp+=" command is suggested put in vimrc.

`right/path/to/vnote` is the directory where clone down this plugin,
maybe `~/.vim/bundle/vnote` is a good choice.

### Install by plugin manage tools

Refer to the plugin manage tool used.
Install "vimloo" before "vnote".

## Fast Usage

* `:NoteNew` create a new note
* `:NoteNew -` create a new diary
* `:w` save note file as normal
* `:NoteList` browse note in notebook
* `:Unite notelist` is available if unite.vim installed
* default notebook is `~/notebook`, it's better to create it first
* `:help vnote` for detail and online document
