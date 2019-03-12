json.array!(@tests) do |test|
  json.extract! test, :id, :field
  json.url test_url(test, format: :json)
end
