# -*- encoding: utf-8 -*-

class Object
  def tee(options={})
    label = options[:label] || options[:l]
    method_name = options[:method] || options[:m] || :inspect

    STDERR.puts ">> #{label}"
    STDERR.puts self.send(method_name)
    STDERR.puts ">>"
    self
  end
end
