# -*- encoding: utf-8 -*-

module Apodidae
  class Manager
    def write_to(output_dir)
      output_fname = "#{output_dir}/app/views/words/edit.html.erb"
      FileUtils.mkdir_p(File.dirname(output_fname))
      raise "File #{output_fname} is alreasy exist." if File.exist?(output_fname)

      open(output_fname, 'w') do |f|
        f.write <<EOS
<%= form_for(@word) do |f| %>
  <div class="field">
    <%= f.label :name %><br />
    <%= f.text_field :name %>
  </div>
  <div class="field">
    <%= f.label :mail %><br />
    <%= f.text_field :mail %>
  </div>
  <div class="actions">
    <%= f.submit %>
  </div>
<% end %>
EOS
      end
    end
  end
end
