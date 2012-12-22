require "rubygems"
require "tmpdir"
require "tempfile"

require 'simplecov'
require 'simplecov-rcov'
SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
SimpleCov.start

BASE_DIR = "#{File.dirname(__FILE__)}/.."

require './lib/apodidae'

RSpec::Matchers.define :be_equal_ignoring_spaces do |expect|
  match do |actual|
    expect, actual = [expect, actual].map do |e|
      e.gsub(/^\s*/, '').gsub(/\s*$/, '').gsub(/ +/, ' ')
    end
    expect == actual
  end
end
