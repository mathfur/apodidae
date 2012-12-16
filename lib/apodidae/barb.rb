# -*- encoding: utf-8 -*-

module Apodidae
  class Barb
    attr_reader :name, :contents

    def initialize(name, contents)
      @name = name.to_s
      @contents = contents
      @sandbox = BarbSandbox.new
    end

    def substitute_rules
      @sandbox.instance_eval(@contents)
      @sandbox.rules
    end

    def add_rachis_attrs(names_and_values)
      @sandbox.substitute_sandbox.add_rachis_attrs(names_and_values)
      self
    end
  end

  class BarbSandbox
    attr_reader :rules, :substitute_sandbox
    def method_missing(*args); end

    def initialize
      @substitute_sandbox = SubstituteSandbox.new
    end

    def substitute(&block)
      @substitute_sandbox.instance_eval(&block)
      @rules = @substitute_sandbox.hash
    end
  end

  class SubstituteSandbox
    attr_reader :hash

    def initialize
      @hash = {}
    end

    def method_missing(name, *args)
      @hash[name] = args
    end

    def add_rachis_attrs(names_and_values)
      self.class.class_eval do
        names_and_values.each do |k, v|
          define_method k do
            return v
          end
        end
      end
    end
  end
end
