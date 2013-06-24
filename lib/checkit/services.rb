module CheckIt
  class Services

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
      dependency_states.each do |name, command_states|
        io.puts " * Gem '#{name}' will need:"
        command_states.each do |cmd, state|
          io.puts "   #{cmd}: #{human_state(state)}"
        end
      end
    end

    private

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
        io.colorize(:alert, 'not installed')
        io.colorize(:help, " Hint: The command might not be in the PATH")
      when :not_running
        io.colorize(:alert, 'not running')
      when :ok
        io.colorize(:notice, 'OK')
      end
    end

  end
end