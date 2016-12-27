require 'filesize'

class Printer

  def self.print_episode_data(episode)
    file_size = Filesize.from(episode.size.to_s + " B").pretty
    puts "Serie               : #{episode.series.name}"
    puts "Episodio #          : #{episode.episode_number}"
    puts "Titulo do Episodio  : #{episode.title}"
    puts "Diretorio Destino   : #{episode.dest_dir}"
    puts "Arquivo Destino     : #{episode.dest_file_name}"
    puts "Arquivo Original    : #{episode.mp3_file}"
    puts "Tamanho do Arquivo  : #{file_size}"
  end

  def self.print_series_full(series_array)
    series_array.each do |series|
      puts "================================== Serie #{series.name} ================================== "

      series.episodes.each do |ep|
        print_episode_data(ep)
      end
    end
  end

end