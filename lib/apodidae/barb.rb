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
      @rules = @substitute_sandbox.items
    end
  end

  class SubstituteSandbox
    attr_reader :items

    def initialize
      @items = []
      @current_name = nil
      @current_labels = nil
    end

    def method_missing(name, *args)
      if name =~ /^__/
        @current_name = nil
        @current_labels = args
      else
        if !@current_name || @current_name == name
          @current_name = name
          @items << SubstituteItem.new(name, @current_labels, args)
        else
          @current_name = nil
          @current_label = nil
          @items << SubstituteItem.new(name, nil, args)
        end
      end
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

  class SubstituteItem
    attr_reader :_name_, :_labels_, :_values_

    def initialize(name, labels, values)
      @_name_ = name.to_s
      @_labels_ = labels && labels.map(&:to_s)
      @_values_ = values
    end

    def [](num)
      if num.kind_of?(Integer)
        @_values_[num]
      else
        raise "labels is not specified (key: #{num})" unless @_labels_
        raise "key `#{num}` is not found in #{@_labels_.inspect}" unless index = @_labels_.index(num.to_s)
        @_values_[index]
      end
    end

    def method_missing(name, *args)
      self[name]
    end
  end
end
