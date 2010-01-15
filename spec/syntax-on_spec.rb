require File.dirname(__FILE__) + '/spec_helper'

describe SyntaxOn do

  it 'can highlight ruby snippet (not from a file)' do
    snippet = SyntaxOn.new "hash = { :chunky => 'BACON' }", :syntax => :ruby
    snippet.to_html.should == "<span class=\"lnr\">1 </span>hash = { <span class=\"Constant\">:chunky</span> =&gt; <span class=\"Special\">'</span><span class=\"Constant\">BACON</span><span class=\"Special\">'</span> }"
  end

  it 'can highlight a saved ruby file'
  it 'auto-detects file type from filename'
  it 'detects language from shabang, if present'
  it 'detects language from modeline, if present'
  it 'can specify whether or not to use line_number'

end

describe SyntaxOn, 'themes' do
  it 'can specify a theme to highlight with'
  it 'can get a list of available themes'
  it 'can add your own theme'
end

describe SyntaxOn, 'configuration' do
  it 'can specify where to look for rc file'
  it 'can override tmp directory via rc file'
  it 'can override tmp directory directly'
  it 'can override options to be passed to vim'
end

describe SyntaxOn, 'caching' do
end

describe SyntaxOn, 'execution' do
  it 'can render using a background BASH session'
end
