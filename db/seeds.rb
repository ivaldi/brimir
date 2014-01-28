# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

frank = User.where(email: 'frank@xxxx.com').first_or_create({ email: 'frank@xxxx.com', password: 'testtest', password_confirmation: 'testtest' })
frank.agent = true
frank.save!

sem = User.where(email: 'sem@xxxx.com').first_or_create({ email: 'sem@xxxx.com', password: 'testtest', password_confirmation: 'testtest' })
sem.agent = true
sem.save!

Status.where(name: 'Deleted').first_or_create!({ name: 'Deleted' })
status_closed = Status.where(name: 'Closed').first_or_create!({ name: 'Closed' })
status_open = Status.where(name: 'Open').first_or_create!({ name: 'Open', default: true })

priority_none = Priority.where(name: 'None').first_or_create!({ name: 'None', default: true })
priority_low = Priority.where(name: 'Low').first_or_create!({ name: 'Low' })
priority_medium = Priority.where(name: 'Medium').first_or_create!({ name: 'Medium' })
priority_high = Priority.where(name: 'High').first_or_create!({ name: 'High' })

password_length = 12
password = Devise.friendly_token.first(password_length)
owner = User.where(email: 'test@xxxx.com').first_or_create!({ email: 'test@xxxx.com', password: password, password_confirmation: password })

Ticket.create!([
  { 
    status_id: status_open.id, 
    user_id: owner.id, 
    subject: 'I have some problems', 
    content: '<pre>I have problems with my computer. Please help</pre>', 
    assignee_id: frank.id, 
    message_id: '1@xxxx.com',
    priority_id: priority_none.id,
  },
  { 
    status_id: status_closed.id, 
    user_id: owner.id, 
    subject: 'I had some problems', 
    content: '<pre>I have problems with my computer. Please help</pre>', 
    message_id: '2@xxxx.com',
    priority_id: priority_high.id, 
  },
  { 
    status_id: status_open.id, 
    user_id: owner.id, 
    subject: 'I had some problems', 
    content: '<pre>I have problems with my computer. Please help</pre>', 
    assignee_id: sem.id, 
    message_id: '3@xxxx.com',
    priority_id: priority_low.id, 
  }
])
