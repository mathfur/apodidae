# -*- encoding: utf-8 -*-

module Apodidae
  class Barb
    attr_reader :name, :contents

    def initialize(name, contents)
      @name = name.to_s
      @contents = contents
    end

    def substitute_rules
      sandbox = BarbSandbox.new
      sandbox.instance_eval(@contents)
      sandbox.src_and_dst
    end
  end

  class BarbSandbox
    attr_reader :src_and_dst
    def substitute(src_and_dst={})
      @src_and_dst = src_and_dst
    end

    def method_missing(*args)
    end
  end
end
