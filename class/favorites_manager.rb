require 'json'
require_relative 'series'
require_relative 'nerdcast'
class FavoritesManager

  def self.fill_favorites(series)
    favorites_series = load_favorites
    favorites_series.each do |serie_fav|
      series.each do |serie_feed|
        if serie_feed.name == serie_fav.name
          serie_fav.episodes.each do |episode_fav|
            serie_feed.episodes.each do |episode_feed|
              if(episode_fav.episode_number == episode_feed.episode_number)
                episode_feed.favorite = true
                episode_feed.duration = episode_fav.duration
                episode_feed.email_start = episode_fav.email_start
                episode_feed.email_end = episode_fav.email_end
              end
            end
          end
        end
      end
    end
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
          nc.episode_number = ep["episode_number"]
          nc.duration = ep["duration"]
          nc.email_start = ep["email_start"]
          nc.email_end = ep["email_end"]

          favorite_episodes.push(nc)
        end

        series.episodes = favorite_episodes
        favorite_series.push(series)
      end
    end

    favorite_series
  end

  #Remove os episodios que nao sao favoritos da lista de episodios de cada serie
  def self.remove_not_starred(series_list)
    series_list.each do |series|
      series.episodes.delete_if { |ep| ep.favorite == false}
    end
  end

end