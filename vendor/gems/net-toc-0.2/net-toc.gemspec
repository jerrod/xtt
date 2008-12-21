require 'rubygems'

spec = Gem::Specification.new do |s|
  s.name = 'net-toc'
  s.has_rdoc = true
  s.version = '0.2'
  s.summary = "A ruby library which uses the TOC protocol to connect to AOL's instant messaging network."
  s.files = ['net/toc.rb']
  s.require_path = '.'
  s.author = 'Ian Henderson'
  s.email = 'ian@ianhenderson.org'
  s.rubyforge_project = 'net-toc'
  s.homepage = "http://net-toc.rubyforge.org"
end
