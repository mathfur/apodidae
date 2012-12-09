# -*- encoding: utf-8 -*-

require "spec_helper"

describe Apodidae::Manager do
  describe "#write_to" do
    describe "when the result of combining rachis and barb is form" do
      before do
        Apodidae::Combine.any_instance.stub(:each).and_yield("app/views/words/edit.html.erb", <<EOS)
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
        @manager = Apodidae::Manager.new
        @relative_fname = "app/views/words/edit.html.erb"
        @output_dir1 = "#{BASE_DIR}/tmp/output"
        @output_dir2 = "#{BASE_DIR}/tmp/output2"

        FileUtils.rm_rf([@output_dir1, @output_dir2])
      end

      describe "when tmp/output is specified" do
        it "output html to tmp/output/app/views/words/edit.html.erb" do
          @manager.write_to(@output_dir1)

          File.read("#{@output_dir1}/#{@relative_fname}").should == <<EOS
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
          File.exist?("#{@output_dir2}/#{@relative_fname}").should be_false
        end
      end

      describe "when tmp/output2 is specified" do
        it "output html to tmp/output2/app/views/words/edit.html.erb" do
          @manager.write_to(@output_dir2)

          File.exist?("#{@output_dir1}/#{@relative_fname}").should be_false
          File.read("#{@output_dir2}/#{@relative_fname}").should == <<EOS
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
end
