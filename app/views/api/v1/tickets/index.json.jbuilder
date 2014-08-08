json.array! @tickets do |ticket|
	json.id			ticket.id
	json.subject 	ticket.subject
	json.date 		ticket.created_at
	json.assignee	ticket.assignee_id
	json.status		ticket.status
	json.priority	ticket.priority
end
