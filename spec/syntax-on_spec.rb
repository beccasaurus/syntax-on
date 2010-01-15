require File.dirname(__FILE__) + '/spec_helper'

describe SyntaxOn, 'highlighting' do

  before do
    @ruby_snippet_html = "<span class=\"lnr\">1 </span>hash = { <span class=\"Constant\">:chunky</span>" + 
                         " =&gt; <span class=\"Special\">'</span><span class=\"Constant\">BACON</span>" + 
                         "<span class=\"Special\">'</span> }"

    @ruby_shabang_html = "<span class=\"lnr\">1 </span><span class=\"PreProc\">#! /usr/bin/ruby</span>\n" + 
                         "<span class=\"lnr\">2 </span>hash = { <span class=\"Constant\">:chunky</span>" + 
                         " =&gt; <span class=\"Special\">'</span><span class=\"Constant\">BACON</span>" + 
                         "<span class=\"Special\">'</span> }"

    @ruby_modeline_html = "<span class=\"lnr\">1 </span>hash = { <span class=\"Constant\">:chunky</span>" + 
                          " =&gt; <span class=\"Special\">'</span><span class=\"Constant\">BACON</span>" + 
                          "<span class=\"Special\">'</span> }" +
                          "\n<span class=\"lnr\">2 </span><span class=\"Comment\"># vim: set ft=ruby:</span>"

    @ruby_no_numbers_html = "hash = { <span class=\"Constant\">:chunky</span> =&gt; " + 
                            "<span class=\"Special\">'</span><span class=\"Constant\">BACON</span>" + 
                            "<span class=\"Special\">'</span> }"
  end

  describe 'from string' do

    it 'can highlight ruby' do
      code = "hash = { :chunky => 'BACON' }"

      SyntaxOn.new( code,          :syntax => :ruby ).to_html.should == @ruby_snippet_html
      SyntaxOn.new( :code => code, :syntax => :ruby ).to_html.should == @ruby_snippet_html
    end

    it 'detects language from shabang, if present' do
      code = "#! /usr/bin/ruby\nhash = { :chunky => 'BACON' }"

      SyntaxOn.new( code          ).to_html.should == @ruby_shabang_html
      SyntaxOn.new( :code => code ).to_html.should == @ruby_shabang_html
    end

    it 'detects language from modeline, if present' do
      code = "hash = { :chunky => 'BACON' }\n# vim: set ft=ruby:"

      SyntaxOn.new( code          ).to_html.should == @ruby_modeline_html
      SyntaxOn.new( :code => code ).to_html.should == @ruby_modeline_html
    end

    it 'can specify whether or not to use line numbers' do
      code = "hash = { :chunky => 'BACON' }"

      SyntaxOn.new( code,          :syntax => :ruby, :line_numbers => false ).to_html.should == @ruby_no_numbers_html
      SyntaxOn.new( :code => code, :syntax => :ruby, :line_numbers => false ).to_html.should == @ruby_no_numbers_html

      # or you can specify it when you render
      SyntaxOn.new( code,          :syntax => :ruby ).to_html( :line_numbers => false ).should == @ruby_no_numbers_html
      SyntaxOn.new( :code => code, :syntax => :ruby ).to_html( :line_numbers => false ).should == @ruby_no_numbers_html
    end

    it 'can highlight something besides ruby to make sure this is really working'

  end

  describe 'from file' do

    it 'can highlight ruby' do
      SyntaxOn.new( :file => file_path('ruby_snippet.rb') ).to_html.should == @ruby_snippet_html
    end

    it 'detects language from shabang, if present' do
      SyntaxOn.new( :file => file_path('ruby_with_shabang.rb') ).to_html.should == @ruby_shabang_html
    end

    it 'detects language from modeline, if present' do
      SyntaxOn.new( :file => file_path('ruby_with_modeline.rb') ).to_html.should == @ruby_modeline_html
    end

    it 'can specify whether or not to use line numbers' do
      SyntaxOn.new( :file => file_path('ruby_snippet.rb'), :line_numbers => false ).to_html.should == @ruby_no_numbers_html
      SyntaxOn.new( :file => file_path('ruby_snippet.rb')).to_html( :line_numbers => false ).should == @ruby_no_numbers_html
    end

    it 'can highlight something besides ruby to make sure this is really working'

  end

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
