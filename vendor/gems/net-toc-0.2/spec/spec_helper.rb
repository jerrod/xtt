require 'rubygems'

dir = File.dirname(__FILE__)
gem 'rspec'

# raise "TODO: attempt to load activerecord and activesupport from gems"
$:.unshift('lib')
require 'ruby-debug'
require 'spec'
require 'net/toc'

Debugger.start