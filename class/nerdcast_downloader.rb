require 'nokogiri'
require 'open-uri'
require 'open_uri_redirections'
require_relative 'nerdcast'
require_relative '../class/favorites_manager'
require_relative '../class/printer'
require_relative '../class/feed_parser'
require_relative '../class/audio_processor'

class NerdcastDownloader

	def download_all
    series_list = FeedParser.get_series
    download_series(series_list)
  end

  def download_favorites
    series_list = FeedParser.get_series
    FavoritesManager.fill_favorites(series_list)
    FavoritesManager.remove_not_starred(series_list)
    download_series(series_list)
  end

  def show_episodes
    series = FeedParser.get_series
    Printer.print_series_full(series)
  end

  def download_series(series_list)
    series_list.each do |series|
      puts '==============================================================================='
      puts "                        Baixando a serie #{series.name}"
      puts '==============================================================================='

      series.episodes.each do |nc|
        download_episode(nc)
        #AudioProcessor.remove_email_part(nc)
      end
      puts
    end
  end

  def verify_if_episode_already_exists(episode)
    episodes_already_exists = false

      if File.size?(episode.dest_file)
        episodes_already_exists = true
      end

    episodes_already_exists
  end

  def download_episode(nc)
    
    begin

      if !Dir.exists?(nc.dest_dir)
        Dir.mkdir(nc.dest_dir)
      end

      Printer.print_episode_data(nc)
      episode_exists = verify_if_episode_already_exists(nc)

      if episode_exists
        puts "Episodio #{nc.title} ja existe."
      else
        File.open(nc.dest_file, "wb") do |saved_file|
          open(nc.mp3_file, "rb", :allow_redirections => :all) do |read_file|
            saved_file.write(read_file.read)
          end
        end
      end

    rescue => error
      puts "Erro ao fazer o dowload do episodio #{nc.title}. #{error}"
      File.delete(nc.dest_file)
    end

    puts
  end

end