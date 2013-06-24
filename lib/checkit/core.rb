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
      # TODO: check if foreman is installed
      check_config_files
      # TODO: notify about test suites
    end

    protected

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
      ConfigFiles.new(io).perform_checks
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