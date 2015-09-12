" Syntax file for mapping.vim


highlight link MyVimMap         vimMap
highlight link MyVimMapModeChar vimSpecial
highlight link MyVimMapNamedKey vimMap

syntax match MyVimMap         '\v^\s*<%(Rem|M)ap>'  skipwhite nextgroup=MyVimMapModeChar
syntax match MyVimMapNamedKey '\v^\s*<MapNamedKey>' skipwhite nextgroup=MyVimMapModeChar,vimMapMod,vimMapLhs
syntax match MyVimMapModeChar '\v[nvxsoic]+' contained skipwhite nextgroup=MyVimMapType,vimMapMod,vimMapLhs
syntax match MyVimMapType     '\v\([^)]+\)'  contained skipwhite nextgroup=vimMapMod,vimMapLhs

syntax cluster vimFuncBodyList add=MyVimMap,MyVimMapNamedKey
