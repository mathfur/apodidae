route_rb(:route, 'show#1') do
  instance_name(:instance_name)
  column(:column)
end

controller_rb(:controller, 'show#1')

view_html(:output, :convert_to_html) do
  input(:view, 'show#1')
end
