require 'bundler'
require 'pp'

$VERBOSE = nil

module CheckIt
  class Core

    attr_accessor :io

    DEPENDENCY_STATES = [:ok, :not_running, :not_installed]

    EXTERNAL_DEPENDENCIES = {
      'pg'          => ['postgres'],
      'mysql'       => ['mysqld'],
      'mysql2'      => ['mysqld'],
      'tire'        => ['elasticsearch'],
      'neography'   => ['neo4j'],
      'redis'       => ['redis-server'],
      'amqp'        => ['rabbitmq-server'],
      'sqlite3'     => ['sqlite3'],
      'carrierwave' => ['convert']
    }

    def initialize(io)
      self.io = io
    end

    def perform_checks
      check_bundle
      check_dependencies
      #check_foreman
      check_config_files
      #notify about tests
    end

    def check_bundle
      simple_check('bundle check', 'Bundle', %(Please run 'bundle install'))
    end

    def check_dependencies
      dependency_states.each do |name, command_states|
        io.puts " * Gem '#{name}' will need:"
        command_states.each do |cmd, state|
          io.print "   #{cmd}: "
          human_state(state)
          io.puts
        end
      end
    end

    def check_config_files
      io.puts " * Config files (just a guess)"
      if File.directory?("config")
        Dir['config/*sample*', 'config/*example*'].each do |example_file|
          cleaned_file_name = example_file.gsub(/\.sample|\.example/, '')
          io.print "   #{cleaned_file_name}: "
          unless File.exists?(cleaned_file_name)
            print_color("Missing", rgb(2, 2, 2), nil)
          end
          io.puts
        end
      else
        print_color("No config directory", rgb(2, 2, 2), nil)
        io.puts
      end
    end

    def self.run(io = STDOUT)
      io.puts "Checking project dependencies:"
      io.puts
      app = self.new(io)
      app.perform_checks
      io.puts
    end

    private

    def set_color(fg, bg)
      io.print "\x1b[38;5;#{fg}m" if fg
      io.print "\x1b[48;5;#{bg}m" if bg
    end

    def reset_color
      io.print "\x1b[0m"
    end

    def print_color(txt, fg, bg)
      set_color(fg, bg)
      io.print txt
      reset_color
    end

    # Each color can have a value between 0 and 5
    def rgb(red, green, blue)
      16 + (red * 36) + (green * 6) + blue
    end


    def simple_check(cmd, message, hint = nil)
      %x[#{cmd}]
      io.print " * #{message}: "
      if $?.exitstatus == 1
        print_color('failed', rgb(5, 0, 0), nil)
        if hint
          puts
          print_color("   Hint: #{hint}", rgb(2, 2, 2), nil)
        end
      else
        print_color('OK', rgb(0, 5, 0), nil)
      end
      io.puts
      $?.exitstatus == 0
    end

    def command_running?(cmd)
      %x[ps acux | grep '#{grepable_command(cmd.clone)}'].class
      $?.exitstatus == 0
    end

    def command_installed?(cmd)
      %x[which #{cmd}]
      $?.exitstatus == 0
    end

    def dependency_states
      @dependency_states ||= begin
        data = {}
        EXTERNAL_DEPENDENCIES.each do |name, commands|
          if bundled_gems.include?(name)
            data[name] = gem_dependency_state(name, commands)
          end
        end
        data
      end
    end

    def gem_dependency_state(name, commands)
      commands.reduce({}) { |memo, cmd| memo[cmd] = command_state(cmd); memo }
    end

    def command_state(cmd)
      if command_installed?(cmd)
        command_running?(cmd) ? :ok : :not_running
      else
        :not_installed
      end
    end

    def grepable_command(cmd)
      cmd.insert(0, '[').insert(2, ']')
    end

    def bundled_gems
      @bundled_gems = Bundler.definition.dependencies.map { |dep| dep.name }
    end

    def human_state(state)
      case state
      when :not_installed
        print_color('not installed', rgb(5, 0, 0), nil)
        print_color(" Hint: The command might not be in the PATH", rgb(2, 2, 2), nil)
      when :not_running
        print_color('not running', rgb(5, 0, 0), nil)
      when :ok
        print_color('OK', rgb(0, 5, 0), nil)
      end
    end

  end
end