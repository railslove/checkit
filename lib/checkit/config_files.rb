module CheckIt
  class ConfigFiles

    attr_accessor :io

    def initialize(io)
      self.io = io
    end

    def perform_checks
      if File.directory?('config')
        check_unmatched_example_files
      else
        io.puts colorize(:help, 'No config directory')
      end
    end

    private

    def check_unmatched_example_files
      Dir['config/*sample*', 'config/*example*'].each do |example_file|
        cleaned_file_name = example_file.gsub(/\.sample|\.example/, '')
        io.print "   #{cleaned_file_name}: "
        output = if File.exists?(cleaned_file_name)
          io.colorize(:notice, 'Ok')
        else
          if %w(.json .yml).include?(File.extname(cleaned_file_name))
            io.colorize(:alert, 'Missing')
          else
            io.colorize(:warning, 'Probably not a config file or a duplicate')
          end
        end
        io.puts output
      end
    end

  end
end