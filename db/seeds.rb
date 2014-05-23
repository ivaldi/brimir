# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

agent = User.where(email: 'agent@getbrimir.com').first_or_create({ email: 'agent@getbrimir.com', password: 'testtest', password_confirmation: 'testtest' })
agent.agent = true
agent.save!

customer = User.where(email: 'customer@getbrimir.com').first_or_create({ email: 'customer@getbrimir.com', password: 'testtest', password_confirmation: 'testtest' })
customer.save!

password_length = 12
password = Devise.friendly_token.first(password_length)
owner = User.where(email: 'test@xxxx.com').first_or_create!({ email: 'test@xxxx.com', password: password, password_confirmation: password })

Ticket.create!([
  {
    status: :open,
    user_id: customer.id,
    subject: 'I have some problems',
    content: '<pre>I have problems with my computer. Please help</pre>',
    assignee_id: agent.id,
    message_id: '1@xxxx.com',
    priority: :unknown,
  },
  {
    status: :closed,
    user_id: owner.id,
    subject: 'I had some problems',
    content: '<pre>I have problems with my computer. Please help</pre>',
    message_id: '2@xxxx.com',
    priority: :high,
  },
  {
    status: :open,
    user_id: owner.id,
    subject: 'I had some problems',
    content: '<pre>I have problems with my computer. Please help</pre>',
    assignee_id: agent.id,
    message_id: '3@xxxx.com',
    priority: :low,
  }
])
