require File.dirname(__FILE__) + '/../lib/syntax-on'
require 'rubygems'
require 'spec'

def file_path *args
  File.join File.dirname(__FILE__), 'files_to_highlight', *args
end
