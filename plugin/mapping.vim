" Vim plugin to define key mappings easily.
" Maintainer: ryym <ryym.64@gmail.com>
" License: This file is placed in the public domain.


" Load this script only once.
if expand('%:p') ==# expand('<sfile>:p')
  unlet! g:loaded_mapping
endif
if exists('g:loaded_mapping')
  finish
endif
let g:loaded_mapping = 1

" Save 'cpoptions'.
let s:save_cpo = &cpo
set cpo&vim


" Define the custom mapping commands.
command! -nargs=+ Map   call mapping#define( 0, mapping#parse_args([<f-args>]) )
command! -nargs=+ Remap call mapping#define( 1, mapping#parse_args([<f-args>]) )
command! -nargs=+ Unmap call mapping#unmap(<f-args>)
command! -nargs=+ MapNamedKey call mapping#map_named_key(<f-args>)


" Restore 'cpoptions'.
let &cpo = s:save_cpo
unlet s:save_cpo


" vim: expandtab softtabstop=2 shiftwidth=2 foldmethod=marker
