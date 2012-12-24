# -*- encoding: utf-8 -*-
require "spec_helper"

describe Apodidae::Edge do
  describe '#initialize' do
    specify do
      Proc.new { Apodidae::Edge.new(:foo, 'html') }.should_not raise_error
    end
  end
end
