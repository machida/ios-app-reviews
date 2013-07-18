class Tasks::Admin
  def self.create_reviewer
    Reviewer.create({
      code: ENV['CODE'].to_i,
      name: ENV['NAME'],
      url: ENV['URL'],
      feed_url: ENV['FEED_URL']
    })
  end
end