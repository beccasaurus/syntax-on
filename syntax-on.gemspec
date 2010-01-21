Gem::Specification.new do |s|
  s.name        = 'syntax-on'
  s.version     = '0.1.13'
  s.summary     = 'vim-based syntax highlighting'
  s.description = 'Syntax-on is a library/cli/website for highlighting source by automating vim'
  s.files       = Dir['{lib,themes}/**/*']
  s.author      = 'remi'
  s.email       = 'remi@remitaylor.com'
  s.homepage    = 'http://github.com/remi/syntax-on'
  s.executables = ['syntax-on']

  s.add_dependency 'simplecli', '> 0.0.0'
end
