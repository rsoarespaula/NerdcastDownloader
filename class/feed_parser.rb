class FeedParser

  def self.get_episodes
    if File.exist?('feed.xml')
      puts 'Arquivo de feed encontrado. Nao irei baixar o feed do site.'
      file = File.new('feed.xml')
      doc = Nokogiri::HTML(open(file))
    else
      puts 'Obtendo feed...'
      doc = Nokogiri::HTML(open('https://jovemnerd.com.br/categoria/nerdcast/feed/'))
      puts 'Feed obtido'
      puts
    end

    series_hash = Hash.new
    series_array = Array.new

    doc.xpath('//channel/item').each do |item|

      title = item.at_xpath('title').content
      # So pega episodios que tem numero, pois tem alguns aleatorios que nao tem,
      # mas nao tem problema, pois nao sao da serie do nerdcast mesmo
      episode_number = get_episode_number(title)
      if episode_number > 0 then
        episode_series_title = get_series_title(title)

        if series_hash.has_key?(episode_series_title)
          series = series_hash[episode_series_title]
        else
          series = Series.new
          series.name = episode_series_title
          series.episodes = Array.new
          series_hash[episode_series_title] = series
        end

        dest_file = title.dup + '.mp3'

        #file_name_destination = title.dup
        dest_file_name = sanitize_filename(dest_file)

        dest_dir = "episodes/#{episode_series_title}"

        dest_file = "#{dest_dir}/#{episode_number} - #{dest_file_name}"

        size = item.at_xpath('enclosure').attr('length').to_i

        nc = Nerdcast.new
        nc.series = series
        nc.episode_number = episode_number

        nc.title = title
        nc.mp3_file = item.at_xpath('enclosure').attr('url')
        nc.dest_dir = dest_dir
        nc.dest_file = dest_file
        nc.dest_file_name = dest_file_name
        nc.size = size
        series.episodes.push(nc)
      end
    end

    #ordena os episodios e vai colocando as series no array
    series_hash.keys.each do |series_key|
      series_obj = series_hash[series_key]
      series_obj.episodes = series_obj.episodes.sort_by { |ep| ep.episode_number}.reverse!
      series_array.push(series_obj)
    end

    series_array
  end

  def self.get_series_title(episode_title)
    first_number_index = episode_title.index(episode_title[/\d+/])-1
    series = episode_title[0...first_number_index]
    series
  end

  def self.get_episode_number(episode_title)
    episode_title[/\d+/].to_i
  end

  def self.sanitize_filename(filename)
    filename = remover_acentos(filename)

    filename.gsub! ' ', '_'

    #filename.gsub!(/^.*(\\|\/)/, '')
    filename.gsub!(/[^0-9A-Za-z.\-]/, '_')
  end

  def self.remover_acentos(texto)
    texto = texto.gsub(/(á|à|ã|â|ä)/, 'a').gsub(/(é|è|ê|ë)/, 'e').gsub(/(í|ì|î|ï)/, 'i').gsub(/(ó|ò|õ|ô|ö)/, 'o').gsub(/(ú|ù|û|ü)/, 'u')
    texto = texto.gsub(/(Á|À|Ã|Â|Ä)/, 'A').gsub(/(É|È|Ê|Ë)/, 'E').gsub(/(Í|Ì|Î|Ï)/, 'I').gsub(/(Ó|Ò|Õ|Ô|Ö)/, 'O').gsub(/(Ú|Ù|Û|Ü)/, 'U')
    texto = texto.gsub(/ñ/, 'n').gsub(/Ñ/, 'N')
    texto = texto.gsub(/ç/, 'c').gsub(/Ç/, 'C')
    texto
  end

end