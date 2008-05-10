class SyntaxOn::Browser

  attr_accessor :request, :response, :current_theme

  def initialize directory = '.'
    @directory = directory || '.'
  end

  def call env
    @pwd = Dir.pwd
    Dir.chdir @directory
    
    @response = Rack::Response.new
    @request  = Rack::Request.new env

    @current_theme ||= 'remi' # set default theme to 'remi'
    @current_theme = request['theme'] if request['theme'] and SyntaxOn.theme_names.include? request['theme']

    if request.path_info[/^\/styles\/(.*)\.css$/]
      response['Content-Type'] = 'text/css'
      response.body = SyntaxOn::theme request.path_info.match(/^\/styles\/(.*)\.css$/)[1]
    else
      response.body = response_for env
    end

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

  def line_number_switcher_link
    <<HTML
    <a href="#" onclick="javascript:for each(var span in document.getElementsByClassName('lnr')){ (span.style.display == 'none') ? span.style.display = 'inline' : span.style.display = 'none'; }">toggle line numbers</a>
HTML
  end

  def theme_selector
    <<HTML
    <select id="theme-selector" onchange="javascript:window.location = window.location.toString().replace(/\\?.*/,'') + '?theme=' + document.getElementById('theme-selector').value">
      <option>... select a theme ...</option>
      #{ SyntaxOn::theme_names.map { |theme| "<option>#{theme}</option>" } }
    </select>
HTML
  end

  def code_layout code = ''
    <<HTML
<html>
  <head>
    <script src="http://jquery.com/src/jquery-latest.js" type="text/javascript"></script>
    <style type="text/css">
    <!--
      select { position: absolute; top: 5px; right: 5px; }
    -->
    </style>
    <link rel="stylesheet" href="/styles/#{ current_theme }.css" type="text/css" />
  <head>
  <body>
<h1>#{ @request.path_info }</h1>
#{ theme_selector }
#{ line_number_switcher_link }
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
