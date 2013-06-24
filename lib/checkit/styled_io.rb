require 'ansi'
require 'delegate'

module CheckIt
  class StyledIO < ::SimpleDelegator
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
      self.puts
      self.puts '+' + '-' * 78 + '+'
      self.puts '| ' + txt.ljust(76) + ' |'
      self.puts '+' + '-' * 78 + '+'
      self.puts
    end
  end
end