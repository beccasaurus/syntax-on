class SyntaxOn::Browser

  def initialize directory = '.'
    @directory = directory || '.'
  end

  def call env
    @pwd = Dir.pwd
    Dir.chdir @directory
    
    response = Rack::Response.new
    request  = Rack::Request.new env
    response.body = response_for env

    Dir.chdir @pwd

    response.finish
  end

  def response_for env
    path = env['PATH_INFO'].sub '/',''

    if File.file? path
      code_layout SyntaxOn.new( nil, :file => path ).to_html
    else
      code_layout
    end
  end

  def file_list
    '<ul>' + Dir['**/*'].map { |file_or_dir| %{<li><a href="/#{file_or_dir}">#{file_or_dir}</a></li>} }.join + '</ul>'
  end

  def code_layout code = ''
    <<HTML
<html>
  <head>
    <script src="http://jquery.com/src/jquery-latest.js" type="text/javascript"></script>
    <style>#{ css }</style>
  <head>
  <body>
<h1>#{ File.join(@directory, '**/*') }</h1>
<hr />
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
    SyntaxOn::theme :murphy
  end

end
