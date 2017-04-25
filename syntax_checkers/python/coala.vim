"============================================================================
"File:        coala.vim
"Description: Syntax checking plugin for syntastic.vim
"Author:      Rohan Bhambhoria <rohan dot vbh at gmail dot com>
"
"============================================================================

if exists('g:loaded_syntastic_python_coala_checker')
    finish
endif
let g:loaded_syntastic_python_coala_checker = 1

let s:save_cpo = &cpo
set cpo&vim

let g:syntastic_python_coala_fname = ""
let g:syntastic_python_coala_args = "--format {file}:{line}:{column}:{message}"

function! SyntaxCheckers_python_coala_GetLocList() dict
    let makeprg = self.makeprgBuild({})

    let errorformat='%f:%l:%c:%m'

    let env = syntastic#util#isRunningWindows() ? {} : { 'TERM': 'dumb' }

    return SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat,
        \ 'env': env })
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'python',
    \ 'name': 'coala'})

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set sw=4 sts=4 et fdm=marker:
