# -*- encoding: utf-8 -*-

class Object
  def tee(options={}, &block)
    label = options[:label] || options[:l]
    method_name = options[:method] || options[:m] || :inspect

    STDERR.puts ">> #{label}"

    if block_given?
      STDERR.puts block.call(self)
    else
      STDERR.puts (method_name == :nothing) ? self : self.send(method_name)
    end

    STDERR.puts ">>"

    self
  end

  def present_or(obj)
    self.present? ? self : obj
  end
end
