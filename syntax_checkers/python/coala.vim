"============================================================================
"File:        coala.vim
"Description: Syntax checking plugin for syntastic.vim
"Author:      Rohan Bhambhoria <rohan dot vbh at gmail dot com>
"
"============================================================================

if exists('g:loaded_syntastic_coala')
    finish
endif
let g:loaded_syntastic_coala = 1

if !exists('g:syntastic_coala')
    let g:syntastic_coala = 1
endif

let s:save_cpo = &cpo
set cpo&vim

let s:coala_new = -1

function! SyntaxCheckers_coala_IsAvailable() dict " {{{1
    if !executable(self.getExec())
        return 0
    endif
    
    try
        let version_output = syntastic#util#system(self.getExecEscaped() . ' --version')
        let coala_version = filter( split(version_output, '\m, \=\|\n'), 'v:val =~# ''\m^\(python[-0-9]*-\|\.\)\=coala[-0-9]*\>''' )[0]
        let parsed_ver = syntastic#util#parseVersion(substitute(coala_version, '\v^\S+\s+', '', ''))
        call self.setVersion(parsed_ver)
        
        let s:coala_new = syntastic#util#versionIsAtLeast(parsed_ver, [1])
    catch /\m^Vim\%((\a\+)\)\=:E684/
        call syntastic#log#ndebug(g:_SYNTASTIC_DEBUG_LOCLIST, 'checker output:', split(version_output, "\n", 1))
        call syntastic#log#error("coala: can't parse version string (abnormal termination?)")
        let s:coala_new = -1
    endtry

    return s:coala_new >= 0
endfunction " }}}1

function! SyntaxCheckers_python_coala_GetLocList() dict " {{{1
    let makeprg = self.makeprgBuild({
        \ 'args_after': (s:coala_new ?
        \       '-f text --msg-template="{path}:{line}:{column}:{C}: [{symbol}] {msg}" -r n' :
        \       '-f parseable -r n -i y') })

    let errorformat =
        \ '%A%f:%l:%c:%t: %m,' .
        \ '%A%f:%l: %m,' .
        \ '%A%f:(%l): %m,' .
        \ '%-Z%p^%.%#,' .
        \ '%-G%.%#'

    let loclist = SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat,
        \ 'env': env })
    
    for e in loclist
        if !s:coala_new
            let e['type'] = e['text'][1]
        endif

        if e['type'] =~? '\m^[EF]'
            let e['type'] = 'E'
        elseif e['type'] =~? '\m^[CRW]'
            let e['type'] = 'W'
        else
            let e['valid'] = 0
        endif

        let e['col'] += 1
        let e['vcol'] = 0
    endfor

    return loclist
endfunction " }}}1

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'python',
    \ 'name': 'coala'})

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set sw=4 sts=4 et fdm=marker:
