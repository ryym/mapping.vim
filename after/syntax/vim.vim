" Syntax file for mapping.vim


highlight link MyVimMap         vimMap
highlight link MyVimMapModeChar vimSpecial

syntax match MyVimMap         '\v^\s*<%(Rem|M)ap>'  skipwhite nextgroup=MyVimMapModeChar
syntax match MyVimMapModeChar '\v[nvxsoic]+' contained skipwhite nextgroup=MyVimMapType,vimMapLhs
syntax match MyVimMapType     '\v\([^)]+\)'  contained skipwhite nextgroup=vimMapLhs

syntax cluster vimFuncBodyList add=MyVimMap
