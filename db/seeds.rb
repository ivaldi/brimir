# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

frank = User.new({ email: 'frank@xxxx.com', password: 'testtest', password_confirmation: 'testtest' })
frank.agent = true
frank.save!

sem = User.create({ email: 'sem@xxxx.com', password: 'testtest', password_confirmation: 'testtest' })
sem.agent = true
sem.save!

Status.create!({ name: 'Deleted' })
status_closed = Status.create!({ name: 'Closed' })
status_open = Status.create!({ name: 'Open', default: true })

password_length = 12
password = Devise.friendly_token.first(password_length)
owner = User.create!(email: 'test@xxxx.com', password: password, password_confirmation: password)

Ticket.create!([
  { status_id: status_open.id, user_id: owner.id, subject: 'I have some problems', content: '<pre>I have problems with my computer. Please help</pre>', assignee_id: frank.id, message_id: '1@xxxx.com' },
  { status_id: status_closed.id, user_id: owner.id, subject: 'I had some problems', content: '<pre>I have problems with my computer. Please help</pre>', message_id: '2@xxxx.com' },
  { status_id: status_open.id, user_id: owner.id, subject: 'I had some problems', content: '<pre>I have problems with my computer. Please help</pre>', assignee_id: sem.id, message_id: '3@xxxx.com' }
])
