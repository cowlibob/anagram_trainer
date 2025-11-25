require_relative "ui"
require_relative "dictionary"
require_relative "store"
require_relative "trainer"

module AnagramTrainer
  class Game
    def initialize(root_dir)
      @dictionary = Dictionary.new(File.join(root_dir, "data", "dictionary.txt"))
      @store = Store.new(File.join(root_dir, "data", "history.json"))
      @trainer = Trainer.new(@dictionary, File.join(root_dir, "data", "level.txt"))
      @session_attempts = []
    end

    def start
      UI.clear_screen
      UI.puts UI.bold(UI.cyan("Welcome to Anagram Trainer!"))

      loop do
        UI.puts "\nMenu:"
        UI.puts "1. Play (Random)"
        UI.puts "2. Training Mode"
        UI.puts "3. View Report"
        UI.puts "4. Exit"
        choice = UI.read_key
        # Handle if read_key returns a symbol (like :esc) or a char
        choice = choice.to_s

        case choice
        when "1"
          play_round
        when "2"
          training_menu
        when "3"
          show_report
        when "4", "esc"
          show_session_summary
          UI.puts "Goodbye!"
          break
        else
          UI.puts UI.red("Invalid choice, please try again.")
        end
      end
    end

    private

    def play_round(target_word = nil, callback = nil)
      target_word ||= @dictionary.random_word
      
      scrambled = target_word.chars.shuffle.join

      # Ensure scrambled is not the same as target
      while scrambled == target_word
        scrambled = target_word.chars.shuffle.join
      end

      start_time = Time.now
      attempts = 0
      cursor_pos = 0
      current_guess = ""
      previous_guesses = []
      # Track available letters from scrambled word
      available_letters = scrambled.downcase.chars.tally

      loop do
        UI.clear_screen
        
        # Display scrambled word with highlighting
        # We need to count chars in current_guess to dim them
        guess_counts = current_guess.chars.tally
        display_str = ""
        scrambled.chars.each do |char|
          if guess_counts[char] && guess_counts[char] > 0
            display_str += UI.dim(char)
            guess_counts[char] -= 1
          else
            display_str += UI.bold(UI.yellow(char))
          end
        end

        UI.puts "Solve this anagram: #{display_str}"
        UI.puts "(Press 'Esc' to give up)"
        
        # Display previous guesses with feedback
        if previous_guesses.any?
          UI.puts "\nPrevious attempts:"
          previous_guesses.each do |guess_info|
            UI.puts "  #{guess_info}"
          end
        end
        
        # Display guess with cursor
        # We can't easily show a cursor in raw mode without moving the terminal cursor
        # simpler approach: print the guess, then move cursor back
        UI.print "\nGuess: #{current_guess}"
        
        # Move cursor back if needed
        diff = current_guess.length - cursor_pos
        UI.print "\e[#{diff}D" if diff > 0

        key = UI.read_key

        if key == "\r" || key == "\n" # Enter
          guess = current_guess.downcase.strip
          
          attempts += 1

          if guess == target_word
            end_time = Time.now
            duration = end_time - start_time
            UI.puts "\n\n#{UI.bold(UI.green("CORRECT!"))}"
            UI.puts "Time: #{duration.round(2)} seconds"
            UI.puts "Attempts: #{attempts}"
            
            # Show definition
            UI.puts "\n#{UI.dim("Fetching definition...")}"
            definition = get_definition(target_word)
            UI.puts "#{UI.bold("Definition:")}"
            UI.puts definition
            
            UI.puts "\n#{UI.dim("Esc to stop, any other key to continue...")}"
            key = UI.read_key
            return :esc if key == :esc

            @store.add_attempt(target_word, duration, true, attempts)
            record_session_attempt(target_word, duration, true, attempts)
            callback.call(true) if callback
            return :solved
          elsif guess.length != target_word.length
            UI.puts UI.red("\nLength mismatch! Word is #{target_word.length} letters long.")
            sleep 1
          else
            feedback = UI.feedback(guess, target_word)
            previous_guesses << feedback
          end
          
          current_guess = "" # Reset for next attempt if not correct
          cursor_pos = 0
          # Reset available letters
          available_letters = scrambled.downcase.chars.tally
        elsif key == :esc
          UI.puts "\nThe word was: #{UI.bold(UI.green(target_word))}"
          
          # Show definition
          UI.puts "\n#{UI.dim("Fetching definition...")}"
          definition = get_definition(target_word)
          UI.puts "#{UI.bold("Definition:")}"
          UI.puts definition
          
          UI.puts "\n#{UI.dim("Esc to stop, any other key to continue...")}"
          key = UI.read_key
          return :esc if key == :esc
          
          @store.add_attempt(target_word, Time.now - start_time, false, attempts)
          record_session_attempt(target_word, Time.now - start_time, false, attempts)
          return :esc
        elsif key == "\u007F" || key == "\b" # Backspace/Delete
          if cursor_pos > 0
            deleted_char = current_guess[cursor_pos - 1].downcase
            current_guess.slice!(cursor_pos - 1)
            cursor_pos -= 1
            # Restore the deleted character to available pool
            available_letters[deleted_char] = (available_letters[deleted_char] || 0) + 1
          end
        elsif key == :left
          cursor_pos -= 1 if cursor_pos > 0
        elsif key == :right
          cursor_pos += 1 if cursor_pos < current_guess.length
        elsif key == "\u0003" # Ctrl-C
          exit
        elsif key.is_a?(String) && key =~ /[a-zA-Z]/
          char_lower = key.downcase
          # Check if this character is available in the scrambled word
          if available_letters[char_lower] && available_letters[char_lower] > 0
            current_guess.insert(cursor_pos, key)
            cursor_pos += 1
            available_letters[char_lower] -= 1
          else
            # Character not available - flash/beep
            UI.flash
          end
        end
      end
    end

    def show_report
      page_size = 10
      current_page = 0
      # Filter out entries with 0 attempts
      full_history = @store.history.select { |h| (h[:attempts] || 1) > 0 }.reverse
      
      loop do
        UI.clear_screen
        UI.puts UI.bold(UI.cyan("--- Performance Report ---"))

        total = full_history.size
        solved = @store.total_solved
        avg_time = @store.average_time

        UI.puts "Total Attempts: #{total}"
        UI.puts "Solved: #{solved}"
        UI.puts "Average Time (Solved): #{avg_time.round(2)}s"

        if total > 0
          total_pages = (total / page_size.to_f).ceil
          # Handle edge case where total > 0 but total_pages might calculate oddly if not careful, 
          # but ceil should work. If total is 0, we don't enter here.
          
          start_index = current_page * page_size
          page_items = full_history.slice(start_index, page_size) || []

          UI.puts "\nHistory (Page #{current_page + 1}/#{total_pages}):"
          page_items.each do |entry|
            status = entry[:solved] ? UI.green("SOLVED") : UI.red("FAILED")
            attempts_str = entry[:attempts] ? "#{entry[:attempts]} attempts" : ""
            UI.puts "#{entry[:word]} - #{status} (#{entry[:time_taken].round(2)}s) #{attempts_str}"
          end

          UI.puts "\n[n] Next Page | [p] Previous Page | [q] Quit"
        else
          UI.puts "\nNo history yet."
          UI.puts "[q] Quit"
        end

        choice = UI.gets("> ").chomp.downcase

        case choice
        when 'n'
          current_page += 1 if total > 0 && current_page < total_pages - 1
        when 'p'
          current_page -= 1 if current_page > 0
        when 'q'
          break
        end
      end
    end

    def training_menu
      loop do
        UI.clear_screen
        UI.puts UI.bold(UI.cyan("--- Training Mode ---"))
        UI.puts "1. Graduated Difficulty (Level Up!)"
        UI.puts "2. Suffix Focus (-ING, -TION, etc.)"
        UI.puts "3. Prefix Focus (UN-, RE-, etc.)"
        UI.puts "4. Back to Main Menu"
        choice = UI.read_key
        choice = choice.to_s

        case choice
        when "1"
          run_training(:graduated)
        when "2"
          run_training(:suffix)
        when "3"
          run_training(:prefix)
        when "4", "esc"
          break
        else
          UI.puts UI.red("Invalid choice.")
          sleep 1
        end
      end
    end

    def run_training(mode)
      # Prompt for level selection
      UI.clear_screen
      current_level = @trainer.current_level
      UI.puts UI.cyan("Current level: #{current_level} letters")
      UI.puts "Press Enter to continue or type a level (5-9):"
      UI.print "> "
      
      input = ""
      loop do
        key = UI.read_key
        if key == "\r" || key == "\n"
          break
        elsif key.is_a?(String) && key =~ /[5-9]/
          input = key
          UI.puts key
          break
        elsif key == :esc
          return
        end
      end
      
      unless input.empty?
        @trainer.set_level(input.to_i)
        UI.puts UI.green("Level set to #{@trainer.current_level}")
        sleep 1
      end
      
      
      # Pre-fetch first word
      word = case mode
             when :graduated
               UI.puts UI.cyan("\nLevel: #{@trainer.current_level} letters")
               @trainer.next_graduated_word
             when :suffix
               @trainer.random_suffix_word
             when :prefix
               @trainer.random_prefix_word
             end

      if word.nil?
        UI.puts UI.red("No words found for this mode!")
        sleep 2
        return
      end

      loop do
        # Pre-fetch next word while user is playing current word
        next_word = case mode
        when :graduated
          @trainer.next_graduated_word
        when :suffix
          @trainer.random_suffix_word
        when :prefix
          @trainer.random_prefix_word
        end
        
        callback = ->(solved) {
          result = @trainer.record_result(solved)
          if result == :level_up
            UI.puts UI.bold(UI.yellow("\n*** LEVEL UP! Increasing word length! ***"))
            sleep 2
          end
        }

        result = play_round(word, callback)
        # If user pressed Esc to stop, exit training
        break if result == :esc
        
        # Move to next word (already pre-fetched)
        
        word = next_word
        
        # Check if we ran out of words
        if word.nil?
          UI.puts UI.red("No more words found for this mode!")
          sleep 2
          break
        end
        
        # Show level for graduated mode
        if mode == :graduated
          UI.puts UI.cyan("\nLevel: #{@trainer.current_level} letters")
        end
      end
    end

    def record_session_attempt(word, time, solved, attempts = 0)
      @session_attempts << { word: word, time: time, solved: solved, attempts: attempts }
    end

    def get_definition(word)
      require 'net/http'
      require 'json'
      
      uri = URI("https://api.dictionaryapi.dev/api/v2/entries/en/#{word}")
      response = Net::HTTP.get_response(uri)
      
      if response.is_a?(Net::HTTPSuccess)
        data = JSON.parse(response.body)
        if data.is_a?(Array) && data.first && data.first['meanings']
          # Get first definition from first meaning
          first_meaning = data.first['meanings'].first
          if first_meaning && first_meaning['definitions'] && first_meaning['definitions'].first
            definition = first_meaning['definitions'].first['definition']
            part_of_speech = first_meaning['partOfSpeech']
            return "(#{part_of_speech}) #{definition}"
          end
        end
      end
      
      "Definition not available."
    rescue
      "Definition not available."
    end

    def show_session_summary
      UI.clear_screen
      UI.puts UI.bold(UI.cyan("--- Session Summary ---"))

      if @session_attempts.empty?
        UI.puts "No games played this session."
      else
        @session_attempts.each do |entry|
          status = entry[:solved] ? UI.green("SOLVED") : UI.red("FAILED")
          UI.puts "#{entry[:word]} - #{status} (#{entry[:time].round(2)}s)"
        end
      end
    end
  end
end
