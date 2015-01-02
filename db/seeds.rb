if ENV['CLEAN'].present?
  User.delete_all
  Label.delete_all
  Rule.delete_all
  Ticket.delete_all
  Reply.delete_all
  Attachment.destroy_all
end

agent = User.where(email: 'agent@getbrimir.com').first_or_create({ email: 'agent@getbrimir.com', password: 'testtest', password_confirmation: 'testtest' })
agent.agent = true
agent.save!

customer = User.where(email: 'customer@getbrimir.com').first_or_create({ email: 'customer@getbrimir.com', password: 'testtest', password_confirmation: 'testtest' })
customer.save!

labels = [
    'bug',
    'feedback',
    'feature-request',
    'change-request',
]

customer.labels << Label.where(name: labels.sample).first_or_create!

customers = [
    'alice@example.com',
    'bob@example.com',
    'charlie@example.com',
    'delta@example.com',
    'edward@example.com',
    'frank@example.com',
    'gerry@example.com',
    'harry@example.com',
]
subjects = [
    'Lorem ipsum dolor sit amet',
    'Consectetur adipiscing elit',
    'Donec a diam lectus. Sed sit amet ipsum mauris.',
    'Maecenas congue ligula ac quam viverra nec consectetur ante hendrerit',
    'Donec et mollis dolor. Praesent et diam eget libero egestas mattis sit amet vitae augue.',
    'Nam tincidunt congue enim, ut porta lorem lacinia consectetur.',
    'Donec ut libero sed arcu vehicula ultricies a non tortor.',
    'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
]

content = [
    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec a diam lectus. Sed sit amet ipsum mauris. Maecenas congue ligula ac quam viverra nec consectetur ante hendrerit. Donec et mollis dolor. Praesent et diam eget libero egestas mattis sit amet vitae augue. Nam tincidunt congue enim, ut porta lorem lacinia consectetur. Donec ut libero sed arcu vehicula ultricies a non tortor. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean ut gravida lorem. Ut turpis felis, pulvinar a semper sed, adipiscing id dolor. Pellentesque auctor nisi id magna consequat sagittis. Curabitur dapibus enim sit amet elit pharetra tincidunt feugiat nisl imperdiet. Ut convallis libero in urna ultrices accumsan. Donec sed odio eros. Donec viverra mi quis quam pulvinar at malesuada arcu rhoncus. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. In rutrum accumsan ultricies. Mauris vitae nisi at sem facilisis semper ac in est.',
    'Vivamus fermentum semper porta. Nunc diam velit, adipiscing ut tristique vitae, sagittis vel odio. Maecenas convallis ullamcorper ultricies. Curabitur ornare, ligula semper consectetur sagittis, nisi diam iaculis velit, id fringilla sem nunc vel mi. Nam dictum, odio nec pretium volutpat, arcu ante placerat erat, non tristique elit urna et turpis. Quisque mi metus, ornare sit amet fermentum et, tincidunt et orci. Fusce eget orci a orci congue vestibulum. Ut dolor diam, elementum et vestibulum eu, porttitor vel elit. Curabitur venenatis pulvinar tellus gravida ornare. Sed et erat faucibus nunc euismod ultricies ut id justo. Nullam cursus suscipit nisi, et ultrices justo sodales nec. Fusce venenatis facilisis lectus ac semper. Aliquam at massa ipsum. Quisque bibendum purus convallis nulla ultrices ultricies. Nullam aliquam, mi eu aliquam tincidunt, purus velit laoreet tortor, viverra pretium nisi quam vitae mi. Fusce vel volutpat elit. Nam sagittis nisi dui.',
    'Suspendisse lectus leo, consectetur in tempor sit amet, placerat quis neque. Etiam luctus porttitor lorem, sed suscipit est rutrum non. Curabitur lobortis nisl a enim congue semper. Aenean commodo ultrices imperdiet. Vestibulum ut justo vel sapien venenatis tincidunt. Phasellus eget dolor sit amet ipsum dapibus condimentum vitae quis lectus. Aliquam ut massa in turpis dapibus convallis. Praesent elit lacus, vestibulum at malesuada et, ornare et est. Ut augue nunc, sodales ut euismod non, adipiscing vitae orci. Mauris ut placerat justo. Mauris in ultricies enim. Quisque nec est eleifend nulla ultrices egestas quis ut quam. Donec sollicitudin lectus a mauris pulvinar id aliquam urna cursus. Cras quis ligula sem, vel elementum mi. Phasellus non ullamcorper urna.',
    'Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. In euismod ultrices facilisis. Vestibulum porta sapien adipiscing augue congue id pretium lectus molestie. Proin quis dictum nisl. Morbi id quam sapien, sed vestibulum sem. Duis elementum rutrum mauris sed convallis. Proin vestibulum magna mi. Aenean tristique hendrerit magna, ac facilisis nulla hendrerit ut. Sed non tortor sodales quam auctor elementum. Donec hendrerit nunc eget elit pharetra pulvinar. Suspendisse id tempus tortor. Aenean luctus, elit commodo laoreet commodo, justo nisi consequat massa, sed vulputate quam urna quis eros. Donec vel.',
]

100.times do |n|
  assignee = nil
  if Random.rand() > 0.8
    assignee = agent
  end

  from = customers.sample
  if Random.rand() > 0.8
    from = customer.email
  end

  ticket = Ticket.create!(
    from: from,
    subject: subjects.sample,
    content: '<html><head></head><body><p>' +
        content[0, 1 + (Random.rand() * 3).round].join('</p><p>') +
        '</p></body></html>',
    assignee: assignee,
    priority: Ticket.priorities.keys.sample,
    status: Ticket.statuses.keys.sample,
  )

  ticket.set_default_notifications!

  if Random.rand() > 0.5
    ticket.labels << Label.where(name: labels.sample).first_or_create!
  end

  (Random.rand() * 4).round.times do
    if Random.rand() > 0.6
      reply = ticket.replies.create!(
        from: (customers + [agent.email]).sample,
        content: '<html><head></head><body><p>' +
            content[0, 1 + (Random.rand() * 3).round].join('</p><p>') +
            '</p></body></html>',
      )
      reply.set_default_notifications!
    end
  end
end
