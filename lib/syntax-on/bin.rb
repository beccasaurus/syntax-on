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

  def highlight_help
    <<doco
Usage: #{ script_name } highlight [OPTIONS] FILE

  Options:
    -p, --preview         Preview file in Firefox
    -t, --theme THEME     Theme to use (default :remi)
    -s, --syntax SYNTAX   Specify syntax to use
    -o, --output FILE     Specify name of file to create

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
    end
    opts.parse! args
    file = args.last
    out  = File.expand_path( options[:output] || "#{ file }.html" )

    if file and File.file? file
      css  = SyntaxOn::theme options[:theme]
      html = SyntaxOn.new( File.read(file), :syntax => options[:syntax] ).to_html
      File.open(out, 'w') do |f|
        f << <<HTML
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
      end
      system("firefox #{out} &") if options[:preview]
    else
      help :highlight
    end
  end

end
