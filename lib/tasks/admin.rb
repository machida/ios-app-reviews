class Tasks::Admin
  def self.create_reviewer
    Reviewer.create({
      code: ENV['code'].to_i,
      name: ENV['name'],
      url: ENV['url'],
      feed_url: ENV['feed_url']
    })
  end
end