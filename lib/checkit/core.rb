$VERBOSE = nil

require 'bundler'
require 'ansi'

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

    def self.run(io = STDOUT)
      self.new(io).perform_checks
      io.puts
    end

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
      print_header('Bundled rubygems')
      simple_check('bundle check', 'Bundle', %(Run 'bundle install'))
    end

    def check_dependencies
      print_header('Server dependencies')
      dependency_states.each do |name, command_states|
        io.puts " * Gem '#{name}' will need:"
        command_states.each do |cmd, state|
          io.puts "   #{cmd}: #{human_state(state)}"
        end
      end
    end

    def check_config_files
      print_header('Configuration files')
      if File.directory?("config")
        Dir['config/*sample*', 'config/*example*'].each do |example_file|
          cleaned_file_name = example_file.gsub(/\.sample|\.example/, '')
          io.print "   #{cleaned_file_name}: "
          output = if File.exists?(cleaned_file_name)
            colorize(:notice, 'Ok')
          else
            if %w(.json .yml).include?(File.extname(cleaned_file_name))
              colorize(:alert, 'Missing')
            else
              colorize(:warning, 'Probably not a config file or a duplicate')
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
        io.print colorize(:alert, 'failed')
        if hint
          io.puts
          io.print colorize(:help, "   Hint: #{hint}")
        end
      else
        io.print colorize(:notice, 'OK')
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
        colorize(:alert, 'not installed')
        colorize(:help, " Hint: The command might not be in the PATH")
      when :not_running
        colorize(:alert, 'not running')
      when :ok
        colorize(:notice, 'OK')
      end
    end

    def colorize(type, text)
      color = case type
      when :alert, :error
        :red
      when :notice, :ok
        :green
      when :help, :warning
        :yellow
      else
        :white
      end
      ANSI.color(color) { text }
    end

    def print_header(txt)
      io.puts
      io.puts '+' + '-' * 78 + '+'
      io.puts '| ' + txt.ljust(76) + ' |'
      io.puts '+' + '-' * 78 + '+'
      io.puts
    end

  end
end