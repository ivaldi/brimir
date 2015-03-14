json.array! @labels do |label|
  json.id label.name
  json.text label.name
end
