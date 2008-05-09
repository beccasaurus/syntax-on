$:.unshift File.dirname(__FILE__)

require 'rubygems'
require 'fileutils'

class Array
  def to_vim_args
    self.map{ |option| %{+"#{ option.gsub('"',"'") }"} }.join ' '
  end
end

class SyntaxOn

  VIM_BIN           = 'vim'
  VIM_OPTIONS       = [ "syntax on" ]
  VIM_RENDER        = [ "exe 'normal zR'", "runtime\\! syntax/2html.vim", "wq", "q" ]
  TEMP_DIRECTORY    = '/tmp/syntax-on'
  TEMP_FILENAME     = lambda { Time.now.strftime '%Y-%d-%m_%Hh-%Mm-%Ss' }
  THEME_PATH        = [ '~/.syntaxon/themes' ]

  attr_accessor :code, :syntax

  def initialize code, options = { :syntax => nil }
    @code   = code
    if options[:file] and File.file? options[:file]
      @file = options[:file] 
      @code = File.read @file
    end
    @syntax = options[:syntax]
  end

  def to_html options = { :line_numbers => true }
    setup_temp_dir
    create_temp_file
    setup_vim_options options
    render
    @html = File.read(@html_file).match(/<pre>(.*)<\/pre>/m)[1].strip
    finish
  end

  def self.themes
    theme_directories.inject([]){ |all,this| all + Dir[File.join(File.expand_path(this), '*.css')] }
  end

  def self.theme_names
    themes.map { |theme| File.basename(theme).sub(/\.css$/,'') }.uniq.sort
  end

  def self.theme name = :remi
    File.read themes.find { |theme| File.basename(theme).downcase == "#{ name }.css".downcase }
  end

  def self.theme_directory
    File.expand_path( File.join( File.dirname(__FILE__), "/../themes/" ))
  end

  def self.theme_directories
    SyntaxOn::THEME_PATH << self.theme_directory
  end

  # add to class, as well, so it can be accessed by THEME_PATH constant
  class << self
    def self.theme_directory
      File.expand_path( File.join( File.dirname(__FILE__), "/../themes/" ))
    end
  end

  private

  def finish
    FileUtils.cd @pwd
    @html
  end

  def setup_temp_dir
    @pwd = FileUtils.pwd
    FileUtils.mkdir_p TEMP_DIRECTORY
    FileUtils.cd      TEMP_DIRECTORY
  end

  def create_temp_file
    @filename = File.join TEMP_DIRECTORY, TEMP_FILENAME.call
    @filename << "_#{ File.basename @file }" if @file
    File.open(@filename, 'w'){|f| f << @code }
  end

  def setup_vim_options options = {}
    @options = VIM_OPTIONS.clone
    @options << "setfiletype #{ @syntax.to_s }" if @syntax
    (options[:line_numbers]) ? @options << 'set number' : @options << 'set nonumber'
  end

  def command_string
    "#{ VIM_BIN } #{ @options.to_vim_args } #{ VIM_RENDER.to_vim_args } #{ @filename } &>/dev/null"
  end

  def render
    @output = `#{ command_string }`
    @html_file = "#{ @filename }.html"
  end

end

rc = File.expand_path '~/.syntaxonrc'
eval File.read(rc) if File.file? rc

unless `which #{ SyntaxOn::VIM_BIN }`.strip =~ /^\/(.*)#{ SyntaxOn::VIM_BIN }$/
  puts "SyntaxOn WARNING: VIM_BIN[#{ SyntaxOn::VIM_BIN.inspect }] not found in PATH"
end
