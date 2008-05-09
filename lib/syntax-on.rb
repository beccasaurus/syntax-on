$:.unshift File.dirname(__FILE__)

require 'rubygems'
require 'fileutils'

class Array
  def to_vim_args
    self.map{ |option| %{+"#{ option.gsub('"',"'") }"} }.join ' '
  end
end

class SyntaxOn

  VIM_BIN         = 'vim'
  VIM_OPTIONS     = [ "syntax on" ]
  VIM_RENDER      = [ "exe 'normal zR'", "runtime\\! syntax/2html.vim", "wq", "q" ]
  TEMP_DIRECTORY  = '/tmp/syntax-on'
  TEMP_FILENAME   = lambda { Time.now.strftime '%Y-%d-%m_%Hh-%Mm-%Ss' }

  attr_accessor :code, :syntax

  def initialize code, options = { :syntax => nil }
    @code   = code
    @syntax = options[:syntax]
  end

  def to_html options = { :line_numbers => true }
    setup_temp_dir
    create_temp_file
    setup_vim_options options
    render
    @html = File.read(@html_file).match(/<pre>(.*)<\/pre>/m)[1].strip
  end

  def self.theme name = :remi
    File.read( File.dirname(__FILE__) + "/../themes/#{ name }.css" )
  end

  private

  def setup_temp_dir
    FileUtils.mkdir_p TEMP_DIRECTORY
    FileUtils.cd      TEMP_DIRECTORY
  end

  def create_temp_file
    @filename = File.join TEMP_DIRECTORY, TEMP_FILENAME.call
    File.open(@filename, 'w'){|f| f << @code }
  end

  def setup_vim_options options = {}
    @options = VIM_OPTIONS.clone
    @options << "setfiletype #{ @syntax.to_s }" if @syntax
    @options << 'set nonumber' if options[:line_numbers] = false
  end

  def command_string
    "#{ VIM_BIN } #{ @options.to_vim_args } #{ VIM_RENDER.to_vim_args } #{ @filename } &>/dev/null"
  end

  def render
    @output = `#{ command_string }`
    @html_file = @filename + '.html'
  end

end

rc = File.expand_path '~/.syntaxonrc'
eval File.read(rc) if File.file? rc

unless `which #{ SyntaxOn::VIM_BIN }`.strip =~ /^\/(.*)#{ SyntaxOn::VIM_BIN }$/
  puts "SyntaxOn WARNING: VIM_BIN[#{ SyntaxOn::VIM_BIN.inspect }] not found in PATH"
end
