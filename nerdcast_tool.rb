require_relative 'class/nerdcast_downloader'

download_type = ARGV[0]

if download_type.nil?
  puts "Informe o tipo de download: 'todos', 'favoritos' ou exibir"
else
  down = NerdcastDownloader.new
  if download_type == 'todos'
    down.download_all
  elsif download_type == 'favoritos'
    down.download_favorites
  elsif download_type == 'exibir'
    down.show_episodes
  end
end