output_html(:output, :convert_to_html) do
  input(:output_html, :simple_table) do
    collection_of_label_value_pairs(:user_data)
  end
end
