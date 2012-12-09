# -*- encoding: utf-8 -*-

module Apodidae
  class Manager
    def initialize
      @barb = nil
      @rachis = nil
      @combine = Apodidae::Combine.new(@barb, @rachis)
    end

    def write_to(output_dir)
      @combine.each do |relative_fname, content|
        output_fname = "#{output_dir}/#{relative_fname}"
        raise "File #{output_fname} is alreasy exist." if File.exist?(output_fname)

        FileUtils.mkdir_p(File.dirname(output_fname))
        open(output_fname, 'w') do |f|
          f.write content
        end
      end
    end
  end
end
