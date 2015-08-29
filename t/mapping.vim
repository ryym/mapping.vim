runtime plugin/mapping.vim

describe '#define()'
  it 'defines key mapping based on the arguments'
    TODO
  end

  it 'defines key mappings in several modes'
    TODO
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
