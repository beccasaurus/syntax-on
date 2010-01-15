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
  VIM_OPTIONS       = [ "syntax on", "let html_use_css = 1", 'let html_use_encoding = "utf8"', "let use_xhtml = 1" ]
  VIM_RENDER        = [ "exe 'normal zR'", "runtime\\! syntax/2html.vim", "wq", "q" ]
  TEMP_DIRECTORY    = '/tmp/syntax-on'
  TEMP_FILENAME     = lambda { Time.now.strftime '%Y-%d-%m_%Hh-%Mm-%Ss' }
  THEME_PATH        = [ '~/.syntaxon/themes' ]
  PREVIEW_COMMAND   = lambda { |file| (Gem::Platform.local.os == 'darwin') ? "open -a Firefox '#{file}'" : "firefox '#{file}' &" }

  attr_accessor :code, :syntax

  def initialize code_or_options, options = nil
    if code_or_options.is_a?(String)
      options ||= {}
      options[:code] = code_or_options
    else
      options = code_or_options
    end

    options[:syntax] ||= nil

    if options[:file] and File.file? options[:file]
      @file = options[:file] 
      @code = File.read @file
    end

    @line_numbers = options[:line_numbers].nil? ? true : options[:line_numbers]

    @code = options[:code] if @code.nil? and options[:code]

    @syntax = options[:syntax]
    @use_session = options[:use_session]
  end

  def to_html options = { :line_numbers => @line_numbers }
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
    "#{ VIM_BIN } #{ @options.to_vim_args } #{ VIM_RENDER.to_vim_args } #{ @filename } 2>/dev/null"
  end

  def render
    if @use_session
      require 'session'
      puts "using Session"
      bash = Session::Bash.new
      bash.execute "cd '#{ TEMP_DIRECTORY }'"
      puts "cd'd to directory ..."
      bash.execute command_string, :stdout => STDOUT, :stderr => STDERR
      # @output, @error = bash.execute command_string
      puts "ran command string ... should return now ..."
    else
      @output = `#{ command_string }`
    end
    @html_file = "#{ @filename }.html"
  end

end

rc = File.expand_path '~/.syntaxonrc'
eval File.read(rc) if File.file? rc

unless `which #{ SyntaxOn::VIM_BIN }`.strip =~ /^\/(.*)#{ SyntaxOn::VIM_BIN }$/
  puts "SyntaxOn WARNING: VIM_BIN[#{ SyntaxOn::VIM_BIN.inspect }] not found in PATH"
end
