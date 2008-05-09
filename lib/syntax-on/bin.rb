require 'optparse'
require 'simplecli'

class SyntaxOn::Bin
  include SimpleCLI

  def usage *args
    puts <<doco

  syntax-on == %{ vim-based syntax highlighing }

    Usage:
      syntax-on -h/--help      [Not Implemented Yet]
      syntax-on -v/--version   [Not Implemented Yet]
      syntax-on command [options]

    Examples:
      syntax-on highlight my-file.rb

    Further help:
      syntax-on commands         # list all available commands
      syntax-on help <COMMAND>   # show help for COMMAND
      syntax-on help             # show this help message

doco
  end 

  def themes_help
    <<doco
Usage: #{ script_name } themes [OPTIONS] [THEME]

  Options:
    -l, --list            List all available themes
    -p, --path            Print out the THEME_PATH directories
    -c, --cat             Cat (show) a theme

  Arguments:
    THEME                 A theme name, eg. 'default'

  Summary:
    Command for managing #{ script_name } themes
  end
doco
  end
  def themes *args
    options = {}
    opts = OptionParser.new do |opts|
      opts.on('-l','--list'){ options[:list] = true }
      opts.on('-p','--path'){ options[:path] = true }
      opts.on('-c','--cat'){ options[:cat] = true }
    end
    opts.parse! args

    theme = args.last

    puts SyntaxOn::themes.sort.join("\n") if options[:list]
    puts SyntaxOn::theme_directories.join("\n") if options[:path]
    puts SyntaxOn::theme(theme) if options[:cat] and theme
  end

  def browser_help
    <<doco
Usage: #{ script_name } server [DIRECTORY]

  Options:
    -p, --port            Port to run on

  Arguments:
    DIRECTORY             Root directory to browse

  Requires gems: thin

  Summary:
    Starts a web server to browse syntax highlighted
    files in the current directory
doco
  end
  def browser *args
    begin
      require 'thin'
    rescue
      puts "Please install the 'thin' gem to run `#{script_name} server`" ; exit
    end

    options = { :port => 6789 }
    opts = OptionParser.new do |opts|
      opts.on('-p','--port [PORT]'){ |port| options[:port] = port }
    end
    opts.parse! args
    dir = args.last
    
    require 'syntax-on/browser'
    Thin::Server.start('0.0.0.0', options[:port].to_i) do
      use Rack::CommonLogger
      use Rack::ShowExceptions
      run SyntaxOn::Browser.new(dir)
    end
  end

  def highlight_help
    <<doco
Usage: #{ script_name } highlight [OPTIONS] FILE

  Options:
    -p, --preview         Preview file in Firefox
    -t, --theme THEME     Theme to use (default :remi)
    -s, --syntax SYNTAX   Specify syntax to use
    -o, --output FILE     Specify name of file to create,
                            output is echoed if -o STDOUT
    -c, --code CODE       Specify code to use in place of 
                            a file (also checks STDIN)

  Arguments:
    FILE                  Name of the file to highlight

  Summary:
    Create a syntax highlighted HTML file
doco
  end
  def highlight *args
    options = { :theme => :remi }
    opts = OptionParser.new do |opts|
      opts.on('-p','--preview'){ options[:preview] = true }
      opts.on('-t','--theme [THEME]'){ |theme| options[:theme] = theme }
      opts.on('-s','--syntax [SYNTAX]'){ |syntax| options[:syntax] = syntax }
      opts.on('-o','--output [FILE]'){ |file| options[:output] = file }
      opts.on('-c','--code [CODE]'){ |code| options[:code] = (code.nil? ? STDIN.readlines.join('') : code) }
    end
    opts.parse! args
    file = args.last
    out  = File.expand_path( options[:output] || "#{ file }.html" )

    if options[:code] or ( file and File.file? file )
      css  = SyntaxOn::theme options[:theme]
      html = SyntaxOn.new( options[:code], :syntax => options[:syntax], :file => file ).to_html
      html = <<HTML
<html>
<head>
  <style type="text/css">
  <!--#{ css }-->
  </style>
</head>
<body>
<pre>
#{ html }
</pre>
</body>
</html>
HTML
      unless options[:output] == 'STDOUT'
        File.open(out, 'w') do |f|
          f << html
        end
        system("firefox #{out} &") if options[:preview]
      else
        puts html
      end
    else
      help :highlight
    end
  end

end
