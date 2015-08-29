runtime plugin/mapping.vim

" Call `mapping#_new_mapinfo`.
function! Mapinfo(...)
  return call('mapping#_new_mapinfo', a:000)
endfunction


describe '#define()'
  before
    mapclear
  end

  it 'defines a key mapping without remapping'
    let mapinfo = Mapinfo(['n'], [], '\a', 'abc')
    call mapping#define(0, mapinfo)

    let maparg = maparg('\a', 'n', 0, 1)
    Expect maparg.rhs     ==# 'abc'
    Expect maparg.noremap to_be_true
  end

  it 'defines a key mapping with remapping'
    let mapinfo = Mapinfo(['n'], [], 'key', '<C-g>')
    call mapping#define(1, mapinfo)

    let maparg = maparg('key', 'n', 0, 1)
    Expect maparg.rhs     ==# '<C-g>'
    Expect maparg.noremap to_be_false
  end

  it 'defines a key mapping with map-arguments'
    let mapinfo = Mapinfo(['n'], ['<buffer>', '<silent>'], '\c', '[abc]<CR>')
    call mapping#define(0, mapinfo)

    let maparg = maparg('\c', 'n', 0, 1)
    Expect maparg.rhs    ==# '[abc]<CR>'
    Expect maparg.buffer to_be_true
    Expect maparg.silent to_be_true
  end

  it 'defines key mappings in several modes'
    let mapinfo = Mapinfo(['n', 'o', 'i'], [], '\a', 'abc')
    call mapping#define(0, mapinfo)

    for mode in ['n', 'o', 'i']
      let maparg = maparg('\a', mode, 0, 1)
      Expect maparg.rhs     ==# 'abc'
      Expect maparg.noremap to_be_true
    endfor
  end
end

describe '#parse_args()'
  it 'converts the arguments for key mappings'
    TODO
  end

  context 'with map-arguments'
    it 'takes map-arguments by a special syntax'
      TODO
    end
  end

  context 'with <SID>'
    it 'converts all <SID> to the specified script id'
      TODO
    end

    it 'throws an exception if no script id is set beforehand'
      TODO
    end
  end

  context 'with special rhs flags'
    it 'converts :f: to function calling'
      TODO
    end

    it 'converts :u: to <C-u> to reset the command-line'
      TODO
    end

    it 'converts :r: to <CR> at end'
      TODO
    end

    it 'converts :s: to <Space> at end'
      TODO
    end

    it 'accepts some combinations of flags'
      TODO
    end

    it 'recognizes :: as the abbreviation for :ur:'
      TODO
    end
  end
end
