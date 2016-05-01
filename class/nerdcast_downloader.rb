require 'nokogiri'
require 'open-uri'
require 'open_uri_redirections'
require 'filesize'
require_relative 'nerdcast'

class NerdcastDownloader

	def download_all
    if !Dir.exists?("episodes")
      Dir.mkdir("episodes")
    end

    episodes = get_episodes
    
    episodes_to_download = select_episodes_to_download(episodes)

    episodes_to_download.each do |nc|
      download_episode(nc)
    end

    puts 
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

  def get_episodes
    file = File.new('feed.xml')

    doc = Nokogiri::XML(file)
    
    episodes_array = Array.new

    doc.xpath('//channel/item').each do |item|

      title = item.at_xpath('title').content

      dest_file = title.dup + ".mp3"

      #file_name_destination = title.dup
      dest_file_name = sanitize_filename(dest_file)

      dest_file = "episodes/" + dest_file_name

      size = item.at_xpath('enclosure').attr('length').to_i

      nc = Nerdcast.new
      nc.title = title
      nc.mp3_file = item.at_xpath('enclosure').attr('url')
      nc.dest_file = dest_file
      nc.dest_file_name = dest_file_name
      nc.size = size
      episodes_array.push(nc)
    end

    episodes_array
  end

  def download_episode(nc)
    
    begin

      file_size = Filesize.from(nc.size.to_s + " B").pretty
      puts "Episodio            : #{nc.title}"
      puts "Arquivo Destino     : #{nc.dest_file}"
      puts "Arquivo Original    : #{nc.mp3_file}"  
      puts "Tamanho do Arquivo  : #{file_size}"  

      File.open(nc.dest_file, "wb") do |saved_file|
        open(nc.mp3_file, "rb", :allow_redirections => :all) do |read_file|
          saved_file.write(read_file.read)
        end
      end
    
    rescue
      puts "Erro ao fazer o dowload do episodio #{nc.title}"
    end

    puts
  end


	def sanitize_filename(filename)
	  filename = remover_acentos(filename)

    filename.gsub! ' ', '_'

    #filename.gsub!(/^.*(\\|\/)/, '')
    filename.gsub!(/[^0-9A-Za-z.\-]/, '_')
	end

  def remover_acentos(texto)
    texto = texto.gsub(/(á|à|ã|â|ä)/, 'a').gsub(/(é|è|ê|ë)/, 'e').gsub(/(í|ì|î|ï)/, 'i').gsub(/(ó|ò|õ|ô|ö)/, 'o').gsub(/(ú|ù|û|ü)/, 'u')
    texto = texto.gsub(/(Á|À|Ã|Â|Ä)/, 'A').gsub(/(É|È|Ê|Ë)/, 'E').gsub(/(Í|Ì|Î|Ï)/, 'I').gsub(/(Ó|Ò|Õ|Ô|Ö)/, 'O').gsub(/(Ú|Ù|Û|Ü)/, 'U')
    texto = texto.gsub(/ñ/, 'n').gsub(/Ñ/, 'N')
    texto = texto.gsub(/ç/, 'c').gsub(/Ç/, 'C')
    texto
  end

end