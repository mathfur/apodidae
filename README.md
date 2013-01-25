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

License
----------
Copyright &copy; 2012 mathfur
Licensed under the [Apache License,  Version 2.0][Apache]
Distributed under the [MIT License][mit].
Dual licensed under the [MIT license][MIT] and [GPL license][GPL].
 
[Apache]: http://www.apache.org/licenses/LICENSE-2.0
[MIT]: http://www.opensource.org/licenses/mit-license.php

[GPL]: http://www.gnu.org/licenses/gpl.html
