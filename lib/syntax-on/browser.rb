class SyntaxOn::Browser

  attr_accessor :directory

  def initialize directory = '.'
    @directory = directory
  end

  def call env
    response = Rack::Response.new
    request  = Rack::Request.new env

    response.body = response_for env

    response.finish
  end

  def response_for env
    path = env['PATH_INFO'].sub '/', ''

    if File.file? File.join(@directory,path)
      code_layout SyntaxOn.new( nil, :file => File.join(@directory,path) ).to_html
    else
      file_list
    end
  end

  def file_list
    "<h1>#{ Dir.pwd }</h1>" +
    '<ul>' + Dir['**/*'].map { |file_or_dir| %{<li><a href="/#{file_or_dir}">#{file_or_dir}</a></li>} }.join + '</ul>'
  end

  def code_layout code
    <<HTML
<html>
  <head>
    <style type="text/css">
    <!--#{ css }-->
    </style>
  <head>
  <body>
<pre>
#{ code }
</pre>
<hr />
#{ file_list }
  </body>
</html>
HTML
  end

  def css # need to fix this ... can't seem to find the theme directory when running in thin ...
    %(
    pre { margin-left: 1pt; padding: 5pt; } pre { color: #e1e1e1; background-color: #030507; }
    .Constant { color: #ca0101; } .Identifier { color: #06989a; } 
    .PreProc { color: #75507b; } .Underlined { color: #75507b; } .Title { color: #75507b; } 
    .Special { color: #75507b; } .Statement { color: #bd9901; } .Type { color: #4e9a06; } 
    .Comment { color: #3465a4; } .lnr { color: #bd9901; } pre a[href] { color: #D52222; } )
  end

end
