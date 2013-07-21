class App < ActiveRecord::Base
  belongs_to :developer
  belongs_to :primary_category, class_name: 'Category'
  has_many :app_categories, dependent: :destroy
  has_many :categories, through: :app_categories
  has_many :app_reviews, dependent: :destroy
  has_many :reviews, through: :app_reviews

  def self.itunes_res_to_params itunes_res
    {
      code:             itunes_res['trackId'],
      name:             itunes_res['trackName'],
      url:              itunes_res['trackViewUrl'],
      price:            itunes_res['price'].to_i,
      formatted_price:  itunes_res['formattedPrice'],
      rating:           itunes_res['averageUserRatingForCurrentVersion'] || 0,
      version:          itunes_res['version'],
      size_mb:          (itunes_res['fileSizeBytes'].to_i / 1000.0 / 1000.0).round(1),
      description:      itunes_res['description'],
      artwork60_url:    itunes_res['artworkUrl60'],
      artwork100_url:   itunes_res['artworkUrl100'],
      artwork512_url:   itunes_res['artworkUrl512'],
      developer:        Developer.where(code: itunes_res['artistId']).first,
      primary_category: Category.where(code: itunes_res['primaryGenreId']).first
    }
  end
end
