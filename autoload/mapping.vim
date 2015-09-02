" Vim plugin to define key mappings easily.
" Maintainer: ryym <ryym.64@gmail.com>
" License: This file is placed in the public domain.

" Save 'cpoptions' {{{1
let s:save_cpo = &cpo
set cpo&vim


" Map, Remap {{{1

" Return the current version.
function! mapping#version()
  return '1.0.0'
endfunction

" Set a script id to be used by the mapping commands.
function! mapping#set_sid(sid)
  if ! empty(a:sid)
    let s:current_sid = '<SNR>' . a:sid . '_'
  endif
endfunction

" Unset the current script id.
function! mapping#unset_sid()
  unlet! s:current_sid
endfunction

" Define the key mapping(s) based on the parsed arguments dictionary.
function! mapping#define(should_remap, parsed_mapinfo)
  let mapinfo  = a:parsed_mapinfo
  let map_cmd  = a:should_remap ? 'map' : 'noremap'
  let map_args = join(mapinfo.map_args, '')
  for mode in mapinfo.mode_chars
    execute mode . map_cmd map_args mapinfo.lhs mapinfo.rhs
  endfor
endfunction

" Parse the arguments of `Map` and `Remap` commands
" and return a dictionary that has information about
" the key mapping.
function! mapping#parse_args(args) abort
  call s:validate_args(a:args)
  let map_args = s:find_map_arguments(a:args)
  let lhs_idx  = 1 + len(map_args)

  let mode_chars = split(a:args[0], '\zs')
  let map_args   = s:convert_map_arguments(map_args)
  let lhs        = a:args[lhs_idx]
  let rhs        = join( a:args[(lhs_idx + 1): ] )

  if rhs =~ '<SID>'
    let rhs = s:resolve_sid(rhs)
  endif
  if rhs =~ '^:'
    let rhs = s:parse_ex_command_rhs(rhs)
  endif

  return mapping#_new_mapinfo(mode_chars, map_args, lhs, rhs)
endfunction

" Create a dictionary used to define key mappings.
function! mapping#_new_mapinfo(mode_chars, map_args, lhs, rhs)
  return {
    \ 'mode_chars' : a:mode_chars,
    \ 'map_args'   : a:map_args,
    \ 'lhs'        : a:lhs,
    \ 'rhs'        : a:rhs
    \ }
endfunction


" Unmap {{{1

" Remove the mapping of the specified `lhs` for the modes.
function! mapping#unmap(mode_chars, lhs) abort
  call s:validate_mode_chars(a:mode_chars)
  for mode in split(a:mode_chars, '\zs')
    execute mode . 'unmap' a:lhs
  endfor
endfunction


" Tools {{{1

function! mapping#_scope()
  return s:
endfunction


" Internal {{{1

" Validate arguments {{{2

function! s:to_dict(array, ...) " {{{
  let value = get(a:, '1', 1)
  let dict = {}
  for key in a:array
    let dict[key] = value
  endfor
  return dict
endfunction " }}}

function! s:validate_args(args) abort
  if len(a:args) < 3
    throw 'mapping: Not enough arguments for mapping'
  endif
  call s:validate_mode_chars(a:args[0])
endfunction

function! s:validate_mode_chars(modes) abort
  let invalid_chars = filter(split(a:modes, '\zs'), '! has_key(s:valid_mode_chars, v:val)')
  if 0 < len(invalid_chars)
    throw 'mapping: Invalid mode chars: ' . a:modes
  endif
endfunction

let s:valid_mode_chars = s:to_dict(['n', 'v', 'x', 's', 'o', 'i', 'c'])

" Parsing map-arguments {{{2

" Find the map-arguments like `<buffer>`, `<silent>`, and so on.
" This selects and returns the strings from the `a:args`
" that can be recognized as map-arguments.
function! s:find_map_arguments(args)
  if a:args[1] !~ '^('
    return []
  endif

  let closed_parens = filter( copy(a:args), "v:val =~ ')$'" )
  if len(closed_parens) == 0
    return []
  endif

  let opt_end_idx = index(a:args, closed_parens[0])
  return a:args[1 : opt_end_idx]
endfunction

" Convert the map-arguments array to an array of
" map-arguments written in default syntax.
function! s:convert_map_arguments(m_args)
  if len(a:m_args) == 0
    return []
  endif

  " Remove parentheses.
  let a:m_args[0]  = a:m_args[0][1:]
  let a:m_args[-1] = a:m_args[-1][:-2]

  return map( filter(a:m_args, '0 < len(v:val)'), "'<' . v:val . '>'" )
endfunction


" Parsing `rhs` {{{2

" Replace `<SID>`s with the currently set script id.
function! s:resolve_sid(rhs)
  if ! exists('s:current_sid')
    throw "mapping: <SID> doesn't defined. Please set <SID> by mapping#set_sid()."
  else
    return substitute(a:rhs, '<SID>', s:current_sid, 'g')
  endif
endfunction

" Parse some special syntaxes of `rhs`.
function! s:parse_ex_command_rhs(rhs)
  let matches = matchlist(a:rhs, '\v^:(\w*):\zs.+$')
  if empty(matches)
    return a:rhs
  endif

  let rhs   = matches[0]
  let flags = matches[1]
  if empty(flags) " ::
    let flags = 'ur'
  endif

  for flag in s:rhs_filters.order
    if flags =~# flag
      let filter = s:rhs_filters.filters[flag]
      let rhs    = printf(filter, rhs)
    endif
  endfor

  return ':' . rhs
endfunction

" The dictionary that stores some filters
" for parsing `rhs` special sintaxes.
let s:rhs_filters = {
  \ 'order': ['f', 'u', 'r', 's'],
  \ 'filters': {
  \   'f': 'call %s<CR>',
  \   'u': '<C-u>%s',
  \   'r': '%s<CR>',
  \   's': '%s<Space>'
  \   }
  \ }


" Restore 'cpoptions' {{{1

let &cpo = s:save_cpo
unlet s:save_cpo

" }}}

" vim: expandtab softtabstop=2 shiftwidth=2 foldmethod=marker
