require "simplecov"
require "coveralls"
SimpleCov.start { add_filter '/spec/' }
Coveralls.wear!

require "resourcerer"
require "rspec/given"
require "pry-byebug"
