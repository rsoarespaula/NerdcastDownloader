require 'scissor'

class AudioProcessor
  def self.remove_email_part(nc)
    file = Scissor(nc.dest_file)

    time_midnight = Time.parse("00:00")
    seconds_email_start = Time.parse(nc.email_start) - time_midnight
    seconds_email_end = Time.parse(nc.email_end) - time_midnight


    file = file[0,seconds_email_start] + file[seconds_email_end, file.duration]

    file.to_file(nc.dest_dir + 'new.mp3')

    puts file
  end
end