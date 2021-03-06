" Syntax file for mapping.vim


highlight link MpgVimMap         vimMap
highlight link MpgVimMapModeChar vimSpecial
highlight link MpgVimUnmap       vimUnmap
highlight link MpgVimMapNamedKey vimMap

syntax match MpgVimMap         '\v^\s*<%(Rem|M)ap>'  skipwhite nextgroup=MpgVimMapModeChar
syntax match MpgVimUnmap       '\v^\s*<Unmap>'       skipwhite nextgroup=MpgVimMapModeChar
syntax match MpgVimMapNamedKey '\v^\s*<MapNamedKey>' skipwhite nextgroup=MpgVimMapModeChar,vimMapMod,vimMapLhs
syntax match MpgVimMapModeChar '\v[nvxsoict]+' contained skipwhite nextgroup=MpgVimMapType,vimMapMod,vimMapLhs
syntax match MpgVimMapType     '\v\([^)]+\)'  contained skipwhite nextgroup=vimMapMod,vimMapLhs

syntax cluster vimFuncBodyList add=MpgVimMap,MpgVimMapNamedKey
