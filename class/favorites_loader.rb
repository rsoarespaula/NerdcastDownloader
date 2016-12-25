require 'json'
require_relative 'series'
require_relative 'nerdcast'
class FavoritesLoader

  def self.star_favorites(series)
    favorites = load_favorites
  end

  def self.load_favorites
    favorite_series = Array.new
    favorites_file = File.read('favorites.json')

    series_fav_file = JSON.parse(favorites_file)

    series_fav_file.each do |series_json|
      series = Series.new
      series.name = series_json["name"]

      episodes = series_json["episodes"]
      if !episodes.nil?
        favorite_episodes = Array.new

        episodes.each do |ep|
          nc = Nerdcast.new
          nc.episode_number = ep
          favorite_episodes.push(nc)
        end

        series.episodes = favorite_episodes
        favorite_series.push(series)
      end
    end

    favorite_series
  end

end