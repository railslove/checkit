require 'bundler'

module CheckIt
  class Core

    attr_accessor :io

    def self.run(io = STDOUT)
      self.new(io).perform_checks
      io.puts
    end

    def initialize(io)
      self.io = StyledIO.new(io)
    end

    def perform_checks
      check_bundle
      check_dependencies
      # check if foreman is installed
      check_config_files
      #notify about tests
    end

    def check_bundle
      io.print_header('Bundled rubygems')
      simple_check('bundle check', 'Bundle', %(Run 'bundle install'))
    end

    def check_dependencies
      io.print_header('Server dependencies')
      Services.new(io).perform_checks
    end

    def check_config_files
      io.print_header('Configuration files')
      if File.directory?("config")
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
      else
        io.puts colorize(:help, 'No config directory')
      end
    end

    private


    def simple_check(cmd, message, hint = nil)
      %x[#{cmd}]
      io.print " * #{message}: "
      if $?.exitstatus == 1
        io.print io.colorize(:alert, 'failed')
        if hint
          io.puts
          io.print io.colorize(:help, "   Hint: #{hint}")
        end
      else
        io.print io.colorize(:notice, 'OK')
      end
      io.puts
      $?.exitstatus == 0
    end

  end
end