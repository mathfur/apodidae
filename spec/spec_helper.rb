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
    @expect, @actual = [expect, actual].map do |e|
      e.gsub(/^\s*/, '').gsub(/\s*$/, '').gsub(/ +/, ' ')
    end
    @expect == @actual
  end

  failure_message_for_should do |actual|
    [
      "actual: ================\n#{@actual}",
      "expect: ================\n#{@expect}",
    ].join("\n")
  end
end

RSpec::Matchers.define :be_same_hash do |expect|
  match do |actual|
    (@actual_is_hash = actual.kind_of?(Hash)) and
    (@expect_is_hash = expect.kind_of?(Hash)) and
    (@keys_is_same = (actual.keys == expect.keys)) and
    (@values_is_same = actual.keys.all?{|k| expect.find{|k_, _| k_ == k}.try(:last) == actual.find{|k_, _| k_ == k}.try(:last)})
  end

  failure_message_for_should do |actual|
    <<-EOS
    actual_is_hash:#{@actual_is_hash.inspect}
    expect_is_hash:#{@expect_is_hash.inspect}
    keys_is_same:#{@keys_is_same.inspect}
    values_is_same:#{@values_is_same.inspect}
    --
    actual:#{actual.inspect}
    expect:#{expect.inspect}
    EOS
  end
end
