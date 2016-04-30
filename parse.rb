require 'nokogiri'
require 'open-uri'
require 'open_uri_redirections'

class DownloadNerdcast 

	def download 
		file = File.new('feed.xml')

		doc = Nokogiri::XML(file)

		doc.xpath('//channel/item').each do |item|
			title = item.at_xpath('title').content

			mp3_file = item.at_xpath('enclosure').attr('url')

      dest_file = title.dup + ".mp3"

      #file_name_destination = title.dup
			dest_file = sanitize_filename(dest_file)

      puts "Episodio          : #{title}"
      puts "Arquivo Destino   : #{dest_file}"
      puts "Arquivo Original  : #{mp3_file}"
      
      download_file(mp3_file, dest_file)
      puts 

		end
	end

  def download_file(file, destination_name)
    Dir.mkdir("episodes")
    destination_name = "episodes/" + destination_name

    file_exists = File.size?(destination_name)
    if file_exists
      puts "Arquivo ja existe, ignorando..."
    else
      puts "Baixando..."

      File.open(destination_name, "wb") do |saved_file|
        open(file, "rb", :allow_redirections => :all) do |read_file|
          saved_file.write(read_file.read)
        end
      end
    end
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

down = DownloadNerdcast.new
down.download