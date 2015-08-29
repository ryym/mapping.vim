runtime plugin/mapping.vim

" Call `mapping#_new_mapinfo`.
function! Mapinfo(...)
  return call('mapping#_new_mapinfo', a:000)
endfunction

" Call `mapping#parse_args` after parsing the
" `a:args_str` by <f-args> in the command.
function ParseArgs(args_str)
  execute 'Parse' a:args_str
  return mapping#parse_args(s:__args)
endfunction
let s:__args = []
command -nargs=+ Parse let s:__args = [<f-args>]

call vspec#hint({ 'scope' : 'mapping#_scope()' })


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
  before
    mapclear
  end

  it 'converts the arguments for key mappings'
    " Most basic pattern.
    let mapinfo = ParseArgs('n <C-g> abc')
    Expect mapinfo == Mapinfo(['n'], [], '<C-g>', 'abc')

    " With multiple modes.
    let mapinfo = ParseArgs('nov gb abc')
    Expect mapinfo == Mapinfo(['n', 'o', 'v'], [], 'gb', 'abc')

    " With unnecessary spaces.
    let mapinfo = ParseArgs('i   <C-a>  : call  Func( 1,  2, 3  ) ')
    Expect mapinfo == Mapinfo(['i'], [], '<C-a>', ': call Func( 1, 2, 3 )')
  end

  context 'with map-arguments'
    it 'recognizes the second argument as map-arguments if it is enclosed with parentheses'
      let mapinfo = ParseArgs('n (buffer) ga :quit<CR>')
      Expect mapinfo == Mapinfo(['n'], ['<buffer>'], 'ga', ':quit<CR>')

      let mapinfo = ParseArgs('n (buffer nowait) gb abc')
      Expect mapinfo == Mapinfo(['n'], ['<buffer>', '<nowait>'], 'gb', 'abc')

      let mapinfo = ParseArgs('n ( buffer unique  ) (lhs) (rhs)')
      Expect mapinfo == Mapinfo(['n'], ['<buffer>', '<unique>'], '(lhs)', '(rhs)')

      " It assumes that `rhs` enclosed with parentheses rarely exists.
      let mapinfo = ParseArgs('n (ga) abc')
      Expect mapinfo == Mapinfo(['n'], ['<ga>'], 'abc', '')
    end

    it 'ignores an empty parentheses'
      let mapinfo = ParseArgs('n () a b')
      Expect mapinfo == Mapinfo(['n'], [], 'a', 'b')

      let mapinfo = ParseArgs('n (  ) a b')
      Expect mapinfo == Mapinfo(['n'], [], 'a', 'b')
    end
  end

  context 'with <SID>'
    before
      call mapping#unset_sid()
    end

    it 'converts all <SID> to the specified script id'
      call mapping#set_sid(100)
      let mapinfo = ParseArgs('n qr :call <SID>func(1)')
      Expect mapinfo == Mapinfo(['n'], [], 'qr', ':call <SNR>100_func(1)')
    end

    it 'throws an exception if no script id is set beforehand'
      Expect expr { ParseArgs('n qr :call \<SID>func(1)') } to_throw '^mapping:'
    end
  end

  context 'with special rhs flags'
    it 'converts :f: to function calling'
      let mapinfo = ParseArgs('n <C-g> :f:Somefunc()')
      Expect mapinfo == Mapinfo(['n'], [], '<C-g>', ':call Somefunc()<CR>')
    end

    it 'converts :u: to <C-u> to reset the command-line'
      let mapinfo = ParseArgs('n <Space>w :u:write<CR>')
      Expect mapinfo == Mapinfo(['n'], [], '<Space>w', ':<C-u>write<CR>')
    end

    it 'converts :r: to <CR> at end'
      let mapinfo = ParseArgs('n <Space>w :r:<C-u>write')
      Expect mapinfo == Mapinfo(['n'], [], '<Space>w', ':<C-u>write<CR>')
    end

    it 'converts :s: to <Space> at end'
      let mapinfo = ParseArgs('n <Space>h :s:<C-u>help')
      Expect mapinfo == Mapinfo(['n'], [], '<Space>h', ':<C-u>help<Space>')
    end

    it 'accepts some combinations of flags'
      let mapinfo = ParseArgs('n -e :fu:exists()')
      Expect mapinfo == Mapinfo(['n'], [], '-e', ':<C-u>call exists()<CR>')

      let mapinfo = ParseArgs('n <Space>h :us:help')
      Expect mapinfo == Mapinfo(['n'], [], '<Space>h', ':<C-u>help<Space>')

      let mapinfo = ParseArgs('n <Space>q :ur:quit')
      Expect mapinfo == Mapinfo(['n'], [], '<Space>q', ':<C-u>quit<CR>')
    end

    it 'recognizes :: as the abbreviation for :ur:'
      let mapinfo = ParseArgs('n <Space>q ::quit')
      Expect mapinfo == Mapinfo(['n'], [], '<Space>q', ':<C-u>quit<CR>')
    end
  end
end
