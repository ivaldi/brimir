json.array! @tickets do |ticket|
	json.id			ticket.id
	json.title 		ticket.subject
	json.date 		ticket.created_at
	json.assignee	ticket.assignee_id
end
