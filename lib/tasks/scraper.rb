class Tasks::Scraping
  def self.all_feeds!
    agent = make_agent

    Reviewer.all.each do |reviewer|
      puts "start: (code: #{reviewer.code}) #{reviewer.name}"
      affiliate_urls_finder = make_finder_for reviewer

      Feedzirra::Feed.fetch_and_parse(reviewer.feed_url).entries.map(&:url).each do |entry_url|
        return if Review.where(url: entry_url).present?

        puts "start: #{entry_url}"
        appcodes = appcodes_of entry_url, affiliate_urls_finder, agent

        agent.get entry_url
        # Review, Categories, Developer, App, AppCategories, AppReviewを登録, 更新
        ActiveRecord::Base.transaction do # TODO: 例外発生時にメール等して処理を続ける
          review = Review.create reviewer_id: reviewer.id, title: agent.page.title, url: agent.page.uri.to_s

          appcodes.each do |appcode|
            itunes_res = ITunesSearchAPI.lookup id: appcode, country: 'JP'

            itunes_res['genreIds'].map(&:to_i).each_with_index do |code, i|
              if Category.where(code: code).blank?
                Category.create name: itunes_res['genres'][i], code: code
              end
            end

            if Developer.where(code: itunes_res['artistId']).blank?
              Developer.create name: itunes_res['artistName'], code: itunes_res['artistId']
            end

            app = App.where(code: itunes_res['trackId']).first
            app_params = App.itunes_res_to_params itunes_res
            if app.blank?
              app = App.create app_params
            else
              app.update_attributes app_params
            end

            AppCategory.where(app_id: app.id).each(&:delete)
            Category.where(code: itunes_res['genreIds'].map(&:to_i)).each do |category|
              AppCategory.create app_id: app.id, category_id: category.id
            end

            AppReview.create app_id: app.id, review_id: review.id
          end
        end
      end
    end
  end

  private
    def self.make_agent
      agent = Mechanize.new
      agent.max_history = 1
      agent.user_agent_alias = 'Mac Safari'
      agent
    end

    def self.make_finder_for reviewer
      case reviewer.code
      when 1 then
        -> page {page.search('img[src="http://img.blog.appbank.net/appdl.png"]').map{|e| e.search('..')[0].attribute('href').to_s}}
      else
        raise "finder for #{reviewer.name} is not implemented."
      end
    end

    def self.itunes_url? url
      not url.match(/^https:\/\/itunes.apple.com/).nil?
    end

    def self.appcodes_of url, finder, agent
      finder.call(agent.get url).map{|affiliate_url|
        agent.get affiliate_url
        url = agent.page.uri.to_s

        3.times do
          break if itunes_url? url
          agent.get url
          url = agent.page.uri.to_s
        end

        itunes_url?(url) ? url.match(/id\d{9}/)[0].gsub(/id/, '').to_i : nil
      }.uniq.delete_if(&:nil?)
    end
end