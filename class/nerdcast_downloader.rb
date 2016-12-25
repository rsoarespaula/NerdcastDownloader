require 'nokogiri'
require 'open-uri'
require 'open_uri_redirections'
require_relative 'nerdcast'
require_relative '../class/favorites_loader'
require_relative '../class/printer'
require_relative '../class/feed_parser'

class NerdcastDownloader

	def download_all
    series_list = FeedParser.get_series

    series_list.each do |series|
      puts "Baixando a serie #{series.name}"

      episodes_to_download = select_episodes_to_download(series.episodes)

      episodes_to_download.each do |nc|
        download_episode(nc)
      end
      puts
    end
  end

  def download_favorites
    fav_loader = FavoritesLoader.new
    favorites = fav_loader.load_favorites

    #episodes = get_series

    #episodes_to_download = select_episodes_to_download(episodes)

    #episodes_to_download.each do |nc|
    #  download_episode(nc)
    #end

    puts
  end

  def show_episodes
    series = FeedParser.get_series
    Printer.print_series_full(series)
  end

  def select_episodes_to_download(episodes)
    episodes_to_download = Array.new

    total_size = 0

    episodes.each do |nc|
      if !File.size?(nc.dest_file)
        episodes_to_download.push(nc)
        total_size += nc.size
      else
        puts "Episodio #{nc.title} ja existe. Ignorando..."
      end
    end

    total_size_pretty = Filesize.from(total_size.to_s + " B").pretty
    puts "Total a ser baixado: #{total_size_pretty}"
    puts

    episodes_to_download
  end

  def download_episode(nc)
    
    begin

      Printer.print_episode_data(nc)

      if !Dir.exists?(nc.dest_dir)
        Dir.mkdir(nc.dest_dir)
      end

      File.open(nc.dest_file, "wb") do |saved_file|
        open(nc.mp3_file, "rb", :allow_redirections => :all) do |read_file|
          saved_file.write(read_file.read)
        end
      end
    
    rescue => error
      puts "Erro ao fazer o dowload do episodio #{nc.title}. #{error}"
      File.delete(nc.dest_file)
    end

    puts
  end

end