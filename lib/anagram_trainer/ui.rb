module AnagramTrainer
  class UI
    require 'readline'
    require 'io/console'

    def self.puts(message)
      Kernel.puts(message)
    end

    def self.print(message)
      Kernel.print(message)
    end

    def self.gets(prompt = "")
      Readline.readline(prompt, true)
    end

    def self.get_char
      STDIN.getch
    end

    # Reads a keypress, including escape sequences for arrow keys
    def self.read_key
      c = STDIN.getch
      return c unless c == "\e"

      # If we get \e, check if there's more data waiting (escape sequence)
      # Wait up to 0.1 seconds for the next char
      if IO.select([STDIN], nil, nil, 0.1)
        begin
          c2 = STDIN.read_nonblock(1)
          if c2 == "["
            if IO.select([STDIN], nil, nil, 0.1)
              c3 = STDIN.read_nonblock(1)
              case c3
              when "A" then return :up
              when "B" then return :down
              when "C" then return :right
              when "D" then return :left
              end
            end
          end
        rescue IO::WaitReadable
          # Should not happen given IO.select, but safe fallback
          return :esc
        end
      end
      
      # If no more data arrived, it's just the Esc key
      :esc
    end

    def self.clear_screen
      system("clear") || system("cls")
    end

    def self.colorize(text, color_code)
      "\e[#{color_code}m#{text}\e[0m"
    end

    def self.dim(text)
      colorize(text, 2)
    end

    def self.flash
      print "\a"  # Terminal bell
    end

    def self.green(text)
      colorize(text, 32)
    end

    def self.red(text)
      colorize(text, 31)
    end

    def self.yellow(text)
      colorize(text, 33)
    end

    def self.cyan(text)
      colorize(text, 36)
    end

    def self.bold(text)
      colorize(text, 1)
    end

    # Mastermind-style feedback
    # Returns a string where characters in the correct position are green
    # and others are default color
    def self.feedback(guess, target)
      output = ""
      guess.chars.each_with_index do |char, index|
        output += if target[index] == char
          green(char)
        else
          char
        end
      end
      output
    end
  end
end
