class AudioProcessor

  def self.remove_email_part(nc)

    if !nc.email_start.nil? && nc.email_start != '00:00:00'
      puts "Cortando parte de emails do episodio"

      dir_sem_email = "#{nc.dest_dir}/sem_email"
      if !Dir.exists?(dir_sem_email)
        Dir.mkdir(dir_sem_email)
      end

      base_file_name = File.basename(nc.dest_file_name, ".mp3")
      file_joined = "#{dir_sem_email}/#{base_file_name}_MP3WRAP.mp3"

      arquivo_cortado_ainda_nao_existe = !File.exists?(file_joined)
      if arquivo_cortado_ainda_nao_existe
        mp3_file_1 = "#{dir_sem_email}/new_1.mp3"
        mp3_file_2 = "#{dir_sem_email}/new_2.mp3"

        cmd_cut_start = "mp3cut -o #{mp3_file_1} -t 00:00:00-#{nc.email_start} \"#{nc.dest_file}\""
        cmd_cut_end = "mp3cut -o #{mp3_file_2} -t #{nc.email_end}-#{nc.duration} \"#{nc.dest_file}\""

        cmd_join = "mp3wrap \"#{dir_sem_email}/#{nc.dest_file_name}\" #{mp3_file_1} #{mp3_file_2}"

        system cmd_cut_start
        system cmd_cut_end
        system cmd_join

        File.delete(mp3_file_1)
        File.delete(mp3_file_2)
      else
        puts "O episodio ja estava cortado"
      end
    else
      puts "Parte de emails do episodio nao sera cortada"
    end
  end

end