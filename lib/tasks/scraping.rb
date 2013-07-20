class Tasks::Scraping
  def self.all_feeds!
    agent = make_agent

    Reviewer.all.each do |reviewer|
      puts "start: (code: #{reviewer.code}) #{reviewer.name}"
      affiliate_urls_finder = make_finder_for reviewer

      entries = Feedzirra::Feed.fetch_and_parse(reviewer.feed_url).entries
      break if entries.blank?
      entries.map{|e| [e.url, e.title]}.each do |entry_url, entry_title|
        next if Review.where(url: entry_url).present?
        agent.get entry_url
        entry_url = agent.page.uri.to_s
        next if Review.where(url: entry_url).present?

        puts "start: #{entry_title}: #{entry_url}"
        begin
          appcodes = appcodes_of entry_url, affiliate_urls_finder, agent

          agent.get entry_url
          # Review, Categories, Developer, App, AppCategories, AppReviewを登録, 更新
          ActiveRecord::Base.transaction do # TODO: 例外発生時にメール等して処理を続ける
            review = Review.create reviewer_id: reviewer.id, title: entry_title, url: agent.page.uri.to_s # リダイレクタ経由を考慮

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
              puts app.name
            end
          end
        rescue => e
          puts "error has occured: #{e}. skipped."
        end
      end
    end
  end

  def self.test_feed reviewer_code
    reviewer = Reviewer.where(code: reviewer_code).first
    raise "reviewer not found by code: #{reviewer_code}" if reviewer.blank?

    agent = make_agent
    finder = make_finder_for reviewer
    entries = Feedzirra::Feed.fetch_and_parse(reviewer.feed_url).entries
    return if entries.blank?
    entries.map{|e| [e.url, e.title]}.each do |entry_url, entry_title|
      puts "start: #{entry_title}: #{entry_url}"
      appcodes = appcodes_of entry_url, finder, agent
      puts appcodes
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
      when 1 then # AppBank
        -> page {page./('img[src="http://img.blog.appbank.net/appdl.png"]').map{|e| e./('..')[0].attribute('href').to_s}}
      when 2 then # AppLibrary
        -> page {page./('img[src="http://app-library.com/wp-content/uploads/2013/01/download2.png"]').map{|e| e./('..')[0].attribute('href').to_s}}
      when 3 then # 男子ハック
        -> page {page./('img[src="http://www.danshihack.com/wordpress_r/wp-content/uploads/2013/02/AppDownloadButton-2.jpg"]').map{|e| e./('..')[0].attribute('href').to_s}}
      when 4 then # あぷまがどっとねっと
        -> page {page./('a[href^="http://click.linksynergy.com/"] > img[src*="phobos.apple.com/"]').map{|e| e./('..')[0].attribute('href').to_s}}
      when 5 then # アップス！
        -> page {page./('a[href^="http://click.linksynergy.com/"] > img[src*="phobos.apple.com/"], a[href^="https://itunes.apple.com/"] > img[src*="phobos.apple.com/"]').map{|e| e./('..')[0].attribute('href').to_s}}
      when 6 then # AppleFan
        -> page {page./('img[src^="http://www.applefan2.com/wp-content/uploads/2010/06/itunes_button"]').map{|e| e./('..')[0].attribute('href').to_s}}
      when 7 then # App Woman
        -> page {page./('#ilink').map{|e| e.attribute('href').to_s}}
      when 8 then # iPhone女子部
        -> page {page./('img[src="http://www.iphonejoshibu.com/wp-content/uploads/2013/04/banner_appstore113.png"]').map{|e| e./('..')[0].attribute('href').to_s}}
      when 9 then # Girl's App
        -> page {page./('img[src="/img/btn_go_itunes_big_01.gif"]').map{|e| e./('..')[0].attribute('href').to_s}}
      when 10 then # iPhone女史
        -> page {page./('img[src="http://www.iphone-girl.jp/wp-content/themes/iphone_joshi_new/img/page/post_btn_app.png"]').map{|e| e./('..')[0].attribute('href').to_s}}
      when 11 then # Ketchapp!
        -> page {page./('.button_iphone').map{|e| e.attribute('href').to_s}}
      when 12 then # iStation
        -> page {page./('img[src="/image/appBtn.jpg"]').map{|e| e./('..')[0].attribute('href').to_s}}
      when 13 then # キッズアプリCOM
        -> page {page./('img[src="http://www.kids-app.com/image/itunes_store_check_red.png"]').map{|e| e./('..')[0].attribute('href').to_s}}
      when 14 then # RainbowApps
        -> page {page./('img[src="http://blog.rainbowapps.com/wp-content/uploads/2010/12/download.png"]').map{|e| e./('..')[0].attribute('href').to_s}}
      when 15 then # Touch Lab
        -> page {page./('a[href^="http://click.linksynergy.com/"]').map{|e| e.attribute('href').to_s}}
      else
        raise "finder for #{reviewer.name} is not implemented."
      end
    end

    def self.itunes_url? url
      not url.match(/^https:\/\/itunes.apple.com/).nil?
    end

    def self.extract_appcode url
      itunes_url?(url) ? url.match(/id\d{9}/)[0].gsub(/id/, '').to_i : nil
    end

    def self.appcodes_of url, finder, agent
      agent.get(url) unless agent.page.present? and (url == agent.page.uri.to_s)
      finder.call(agent.page).uniq.map{|affiliate_url|
        begin
          agent.get affiliate_url
          url = agent.page.uri.to_s

          3.times do
            break if itunes_url? url
            agent.get url
            url = agent.page.uri.to_s
          end

        rescue Mechanize::ResponseCodeError => e
          extract_appcode e.page.uri.to_s
        else
          extract_appcode url
        end
      }.uniq.delete_if(&:nil?)
    end
end