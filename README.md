Apodidae
========
Apodidae is a general code generater from DSL.
 
Usage
------

At the first, 
```shell
$ git clone https://github.com/mathfur/apodidae.git
$ cd apodidae
$ rake build
$ gem install pkg/apodidae-0.0.3.gem
```

You create some barb files.
Example:
```ruby
# data/barb/sample_barb.barb
#-->> gsub_by(Edge.new(:inner) => 'hello') do
#-->> output_to Edge.new(:foo) do
<div>hello</div>
#-->> end
#-->> end
```

and, then you create some rachis files.
Example:
```ruby
# data/rachis/foo.rachis
str1 'abc'
```

and, then you create some connection files.
Example:
```ruby
# tmp/connection/foo.rb
output(:foo, :sample_barb) do
  inner(:str1)
end
```

You write a connection_file, then the following command create a file specified by output_filename.
```shell
$ apodidae
  --barb-dir=data/barb
  --rachis-dir=data/rachis
  --connection-file=data/connection/foo.rb
  --output-file=output:tmp/foo.html
```

As the result, tmp/foo.html is created.

Other Example
-------------
Barb:
```ruby
#-->> gsub_by(Edge.new(:input, :prehtml) => 'Prehtml_src') do
#-->> output_to Edge.new(:baz, :html) do
#--==   Prehtml.new(Prehtml_src).to_html
#-->> end
#-->> end
```
```ruby
#-->> output_to Edge.new(:output_html) do
tag(:table) do
  tag(:tr) do
    #-->> loop_by(Edge.new("collection_of_label_value_pairs.first.keys") => ['label']) do
    tag(:th) { 'label' }
    #-->> end
  end
  #-->> loop_by(Edge.new(:collection_of_label_value_pairs, [:range, {:html => :html}]) => ['label_value_pairs']) do
  tag(:tr) do
    #-->> loop_by(Edge.new(:label_value_pairs) => ['label', 'value']) do
    tag(:td) { 'value' }
    #-->> end
  end
  #-->> end
end
#-->> end
```
```ruby
#-->> output_to Edge.new(:output1) do
  #-->> gsub_by(Edge.new('arr.first') => 'first_val') do
  tag(:span){ 'first_val' }
  #-->> end
#-->> end
#-->> output_to Edge.new(:output2) do
  #-->> gsub_by(Edge.new('arr.last') => 'last_val') do
  tag(:div){ 'last_val' }
  #-->> end
#-->> end
```
```ruby
#-->> gsub_by(Edge.new(:eight, [:integer]) => 'x') do
#-->> output_to Edge.new(:nine, [:integer]) do
#--==   1+x
#-->> end
#-->> end
```
```ruby
#-->> output_to Edge.new(:output) do
#-->> loop_by(Edge.new(:input, {:str => :html}) => ['WORD', 'MEANING']) do
tag(:dl) do
  tag(:dt) { 'WORD' }
  tag(:dd) { 'MEANING' }
end
#-->> end
#-->> end
```
```ruby
#-->> output_to Edge.new(:output) do
tag(:table) do
  #-->> loop_by(Edge.new(:input, [:range,{:html => :html}]) => ['row', '__i__']) do
  tag(:tr) do
    #-->> loop_by(Edge.new(:row) => ['name', 'Suzuki']) do
    tag(:td) { 'Suzuki' }
    #-->> end
  end
  #-->> end
end
#-->> end
```
```ruby
#-->> output_to Edge.new(:output) do
#-->> loop_by(Edge.new("input{|e| e.merge('abc' => 'def') }",{:str => :html}) => ['WORD', 'MEANING']) do
tag(:dl) do
  tag(:dt) { 'WORD.{|e| e.upcase }' }
  tag(:dd) { 'MEANING' }
end
#-->> end
#-->> end
```
```ruby
#-->> output_to Edge.new(:output) do
tag(:table) do
  #-->> gsub_by(Edge.new(:instance_name) => 'user_', Edge.new("instance_name.pluralize") => 'users') do
  rb_block("@users.each", "user_") do
    tag(:tr) do
      #-->> loop_by(Edge.new("hashs") => ['column']) do
      tag(:th){ 'column.{|e| e[:label] }' }
      #-->> end
    end
    tag(:tr) do
      #-->> loop_by(Edge.new("hashs") => ['row']) do
      tag(:td, :width => row.{|e| e[:width] }){ row.{|e| e[:rb_statement] } }
      #-->> end
    end
  end
  #-->> end
end
#-->> end
```
```ruby
#-->> gsub_by(Edge.new(:instance_name) => 'useR', Edge.new("instance_name.pluralize") => 'users') do
  #-->> output_to Edge.new(:route) do
  resources :users
  #-->> end

  #-->> output_to Edge.new(:controller) do
  def show
    @useR = useR...camelize.find(params[:id])

    respond_to do |format|
      format.html
      format.json { render json: @useR }
    end
  end
  #-->> end

  #-->> output_to Edge.new(:view) do
    tag(:p, :id=>"notice"){ rb("notice") }

    #-->> loop_by(Edge.new(:column) => ['mail']) do
    tag(:p) do
      tag(:b){ "mail...camelize:" }
      rb("@useR.mail")
    end

    #-->> end
    rb("link_to 'Edit', edit_useR_path(@useR)")
    rb("link_to 'Back', users_path")
  #-->> end
#-->> end
```

Connection:
```ruby
abc(:baz, :convert_to_html) do
  input(:foo, :sample_barb) do
    inner(:str1)
  end
end
```
```ruby
abc(:foo, :foo) do
  inner(:str1)
end
xyz(:foo, :foo) do
  inner(:str2)
end
```
```ruby
output_html(:output, :convert_to_html) do
  input(:output_html, :simple_table) do
    collection_of_label_value_pairs(:user_data)
  end
end
```
```ruby
output1(:output1, '2way#1') do
  arr(:arr)
end

output2(:output2, '2way#1')
```

Rachis:
```ruby
str1 'abc'
str2 'xyz'
```
```ruby
group :user_data, :labels => ['氏名', 'メールアドレス', '年齢'] do
  row 'Suzuki', 'suzuki@gmail.com', '29'
  row 'Sato',   'sato@gmail.com',   '30'
end
```
```ruby
arr %w{foo bar baz}
```

License
----------
Copyright &copy; 2012 mathfur
Licensed under the [Apache License,  Version 2.0][Apache]
Distributed under the [MIT License][mit].
Dual licensed under the [MIT license][MIT] and [GPL license][GPL].
 
[Apache]: http://www.apache.org/licenses/LICENSE-2.0
[MIT]: http://www.opensource.org/licenses/mit-license.php

[GPL]: http://www.gnu.org/licenses/gpl.html
