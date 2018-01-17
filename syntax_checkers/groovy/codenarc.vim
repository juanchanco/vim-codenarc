"============================================================================
"File:        codenarc.vim
"Description: Syntax checking plugin for syntastic
"Maintainer:  Juan Chanco <juan.chanco at bluestembrands dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================

if exists('g:loaded_syntastic_groovy_codenarc_checker')
    finish
endif
let g:loaded_syntastic_groovy_codenarc_checker = 1

"NOTE: is there a way to get the current project classpath
" (for the enhanced.xml ruleset
if !exists('g:syntastic_groovy_codenarc_classpath')
    let g:syntastic_groovy_codenarc_classpath = join(globpath(expand('<sfile>:p:h:h:h>'), '/lib/*.jar', 0, 1), ':')
endif

if !exists('g:syntastic_groovy_codenarc_rulesets')
    let g:syntastic_groovy_codenarc_rulesets = 'rulesets/basic.xml'
endif

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_groovy_codenarc_IsAvailable() dict
    return executable(self.getExec())
endfunction

function! PreprocessCodenarc(errors) abort
    return map(copy(a:errors), 'substitute(v:val, ''P=\([123]\)'', {m -> m[1]=="1" ? "P=E" : "P=W"}, "")')
endfunction

function! SyntaxCheckers_groovy_codenarc_GetLocList() dict

    let buf = bufnr('')

    " classpath
    if !exists('s:sep')
        let s:sep = syntastic#util#isRunningWindows() || has('win32unix') ? ';' : ':'
    endif
    let classpath = join(map( split(g:syntastic_groovy_codenarc_classpath, s:sep, 1), 'expand(v:val, 1)' ), s:sep)
    call self.log('classpath =', classpath)

    " filename
    "TODO: what does the path need to be for window?
    if has('win32unix')
        let fname = substitute(syntastic#util#system('cygpath -m ' . fnamemodify(bufname(buf), ':.')), '\m\%x00', '', 'g')
    else
        let fname = syntastic#util#shescape( '.' . syntastic#util#Slash() . fnamemodify(bufname(buf), ':.') )
    endif

    " forced options
    let opts = []
    if classpath !=# ''
        call extend(opts, ['-cp', classpath])
    endif
    "TODO: make rulesetfiles configurable
    call extend(opts, [
        \ 'org.codenarc.CodeNarc',
        \ '-report=console',
        \ ('-rulesetfiles=' . g:syntastic_groovy_codenarc_rulesets),
        \ ('-includes=' . fname)])

    let makeprg = self.makeprgBuild({ 'args_after': opts, 'fname': '' })

    let errorformat = '%+PFile:\ %f,\ %#Violation:\ Rule=%.%#\ P=%t\ Line=%l\ Msg=[%m]\ Src=%.%#,\ %#Violation:\ Rule=%m\ P=%t\ Line=%l\ Src=%.%#,%-Q'

    return SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat,
        \ 'Preprocess': 'PreprocessCodenarc',
        \ 'subtype': 'Style' })
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'groovy',
    \ 'name': 'codenarc',
    \ 'exec': 'java'})

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set sw=4 sts=4 et fdm=marker:
