json.array! @tickets do |ticket|
	json.id			ticket.id
	json.subject 	ticket.subject
end
