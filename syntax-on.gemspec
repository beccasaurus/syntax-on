Gem::Specification.new do |s|
  s.name = "syntax-on"
  s.version = "0.1.8"
  s.date = "2008-05-09"
  s.summary = "vim-based syntax highlighting"
  s.email = "remi@remitaylor.com"
  s.homepage = "http://github.com/remi/syntax-on"
  s.description = "Syntax-on is a library/cli/website for highlighting source by automating vim"
  s.has_rdoc = true
  s.rdoc_options = ["--quiet", "--title", "syntax-on - vim-based syntax highlighting", "--opname", "index.html", "--line-numbers", "--main", "README", "--inline-source"]
  s.extra_rdoc_files = ['README']
  s.authors = ["remi Taylor"]
  s.files = ["bin/syntax-on", "lib/syntax-on.rb", "lib/syntax-on/bin.rb", "lib/syntax-on/browser.rb", "themes/rubyblue.css", "themes/peachpuff.css", "themes/blue.css", "themes/generate-theme-files", "themes/darkblue.css", "themes/slate.css", "themes/murphy.css", "themes/elflord.css", "themes/desert.css", "themes/koehler.css", "themes/pablo.css", "themes/default.css", "themes/delek.css", "themes/evening.css", "themes/morning.css", "themes/ron.css", "themes/remi.css", "themes/zellner.css", "themes/torte.css", "themes/shine.css", "README", "TODO"]
  s.add_dependency("remi-simplecli", ["> 0.0.0"])
  s.executables = ["syntax-on"]
  s.default_executable = "syntax-on"
end
