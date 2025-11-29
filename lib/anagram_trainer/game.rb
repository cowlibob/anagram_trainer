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

    private

    def async_sleep(seconds)
      sleep seconds
    end

    public

    def start
      UI.clear_screen
      UI.puts UI.bold(UI.cyan("Welcome to Anagram Trainer!"))

      loop do
        UI.puts "\nMenu:"
        UI.puts "1. Play (Random)"
        UI.puts "2. Training Mode"
        UI.puts "3. Train Me (Campaign)"
        UI.puts "4. Leaderboard"
        UI.puts "5. View Report"
        UI.puts "6. Exit"
        choice = UI.read_key
        # Handle if read_key returns a symbol (like :esc) or a char
        choice = choice.to_s

        case choice
        when "1"
          play_round
        when "2"
          training_menu
        when "3"
          run_campaign
        when "4"
          show_leaderboard
        when "5"
          show_report
        when "6", "esc"
          show_session_summary
          UI.puts "Goodbye!"
          break
        else
          UI.puts UI.red("Invalid choice, please try again.")
        end
      end
    end

    private

    def run_campaign
      # Load progress or start new
      progress = @store.load_campaign_progress
      if progress
        UI.clear_screen
        UI.puts UI.bold(UI.cyan("Resume Campaign?"))
        UI.puts "Stage: #{AnagramTrainer::Trainer::CAMPAIGN_STAGES[progress[:stage_index]][:name]}"
        UI.puts "Score: #{progress[:score]}"
        UI.puts "\n[y] Resume  [n] New Game"
        choice = UI.read_key
        if choice.to_s.downcase == 'n'
          progress = nil
        end
      end

      start_stage = progress ? progress[:stage_index] : 0
      start_score = progress ? progress[:score] : 0
      
      campaign = @trainer.start_campaign(start_stage: start_stage, start_score: start_score)
      
      loop do
        if campaign.completed?
          show_leaderboard_entry(campaign.score)
          break
        end

        stage = campaign.current_stage
        
        # Show stage intro if starting new stage
        if campaign.words_remaining == stage[:count]
          UI.clear_screen
          UI.puts UI.bold(UI.cyan("--- Stage #{campaign.stage_index + 1}: #{stage[:name]} ---"))
          
          # Show hints if available
          hints = @trainer.hints(stage[:mode])
          if hints.any?
            UI.puts "\nLook for: #{UI.yellow(hints.join(', '))}"
          end
          
          UI.puts "\nGet ready..."
          async_sleep 2
        end

        word = campaign.next_word
        if word.nil?
          UI.puts UI.red("Error: No word found for stage #{stage[:name]}")
          async_sleep 2
          break
        end

        # Custom play_round for campaign to show score/progress
        UI.clear_screen
        UI.puts "#{UI.cyan(stage[:name])} | Score: #{UI.yellow(campaign.score)} | Remaining: #{campaign.words_remaining}"
        
        start_time = Time.now
        result = play_round(word)
        duration = Time.now - start_time

        if result == :solved
          success_data = campaign.record_success(duration)
          
          UI.puts "\nPoints: #{success_data[:points]}"
          if success_data[:points] > 100
            UI.puts UI.yellow("SPEED BONUS! +#{success_data[:points] - 100}") 
          end
          
          @store.save_campaign_progress(campaign.stage_index, campaign.score)
          
          if success_data[:stage_complete]
            UI.puts UI.bold(UI.green("\n*** STAGE COMPLETE! ***"))
            async_sleep 2
          else
            async_sleep 1
          end
        elsif result == :esc
          # Player exited - offer to save score to leaderboard
          if campaign.score > 0
            show_leaderboard_entry(campaign.score, partial: true)
          end
          break
        end
      end
    end

    def show_leaderboard_entry(score, partial: false)
      UI.clear_screen
      if partial
        UI.puts UI.bold(UI.yellow("Campaign Ended"))
        UI.puts "Your Score: #{UI.bold(UI.green(score.to_s))}"
      else
        UI.puts UI.bold(UI.yellow("*** CAMPAIGN COMPLETE! ***"))
        UI.puts "Final Score: #{UI.bold(UI.green(score.to_s))}"
      end
      
      # Check if score qualifies for leaderboard
      leaderboard = @store.get_leaderboard
      qualifies = leaderboard.length < 10 || score > leaderboard.last[:score]
      
      if qualifies
        UI.puts "\n#{UI.bold(UI.cyan('You made the leaderboard!'))}"
        UI.puts "Enter your name (max 20 chars):"
        UI.print "> "
        
        name = ""
        loop do
          key = UI.read_key
          if key == "\r" || key == "\n"
            break if name.length > 0
          elsif key == "\u007F" || key == "\b"
            if name.length > 0
              name = name[0...-1]
              UI.print "\b \b"
            end
          elsif key.is_a?(String) && key =~ /[a-zA-Z0-9 ]/ && name.length < 20
            name += key
            UI.print key
          end
        end
        
        @store.save_leaderboard_entry(name, score)
      else
        UI.puts "\n#{UI.dim('Score did not make the top 10.')}"
      end
      
      # Show leaderboard
      UI.clear_screen
      UI.puts UI.bold(UI.cyan("=== LEADERBOARD ==="))
      leaderboard = @store.get_leaderboard
      leaderboard.each_with_index do |entry, i|
        rank = "#{i + 1}."
        name_display = entry[:name].ljust(20)
        score_display = entry[:score].to_s.rjust(6)
        
        # Format date as DD/MM/YYYY
        begin
          require 'date'
          date = DateTime.parse(entry[:date].to_s)
          date_display = date.strftime("%d/%m/%Y")
        rescue
          date_display = "Unknown"
        end
        
        if qualifies && entry[:name] == name && entry[:score] == score
          UI.puts UI.bold(UI.yellow("#{rank} #{name_display} #{score_display}  #{date_display}"))
        else
          UI.puts "#{rank} #{name_display} #{score_display}  #{UI.dim(date_display)}"
        end
      end
      
      unless partial
        UI.puts "\nCongratulations! You are a master anagram solver!"
      end
      UI.puts "\nPress any key to continue..."
      UI.read_key
      # Reset progress
      @store.save_campaign_progress(0, 0)
    end

    def show_leaderboard
      UI.clear_screen
      UI.puts UI.bold(UI.cyan("=== LEADERBOARD ==="))
      
      leaderboard = @store.get_leaderboard
      
      if leaderboard.empty?
        UI.puts "\nNo scores yet. Complete the Train Me campaign to get on the board!"
      else
        leaderboard.each_with_index do |entry, i|
          rank = "#{i + 1}.".ljust(4)
          name_display = entry[:name].ljust(20)
          score_display = entry[:score].to_s.rjust(6)
          
          # Format date as DD/MM/YYYY
          begin
            require 'date'
            date = DateTime.parse(entry[:date].to_s)
            date_display = date.strftime("%d/%m/%Y")
          rescue
            date_display = "Unknown"
          end
          
          UI.puts "#{rank}#{name_display} #{score_display}  #{UI.dim(date_display)}"
        end
      end
      
      UI.puts "\nPress any key to return..."
      UI.read_key
    end

    def play_round(target_word = nil)
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
            return :solved
          elsif guess.length != target_word.length
            UI.puts UI.red("\nLength mismatch! Word is #{target_word.length} letters long.")
            async_sleep 1
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
        UI.puts "4. Digraphs (TH, HE, etc.)"
        UI.puts "5. Trigraphs (THE, AND, etc.)"
        UI.puts "6. Vowel Clusters (EA, OU, etc.)"
        UI.puts "7. Consonant Blends (ST, BL, etc.)"
        UI.puts "8. Back to Main Menu"
        choice = UI.read_key
        choice = choice.to_s

        case choice
        when "1"
          run_training(:graduated)
        when "2"
          run_training(:suffix)
        when "3"
          run_training(:prefix)
        when "4"
          run_training(:digraph)
        when "5"
          run_training(:trigraph)
        when "6"
          run_training(:vowel_cluster)
        when "7"
          run_training(:consonant_blend)
        when "8", "esc"
          break
        else
          UI.puts UI.red("Invalid choice.")
          async_sleep 1
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
        async_sleep 1
      end
      
      # Display hints
      hints = @trainer.hints(mode)
      if hints.any?
        UI.clear_screen
        UI.puts UI.bold(UI.cyan("--- Training Hints ---"))
        UI.puts "Look for these common patterns:"
        UI.puts UI.yellow(hints.join(", "))
        UI.puts "\nPress any key to start..."
        UI.read_key
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
             when :digraph
               @trainer.random_digraph_word
             when :trigraph
               @trainer.random_trigraph_word
             when :vowel_cluster
               @trainer.random_vowel_cluster_word
             when :consonant_blend
               @trainer.random_consonant_blend_word
             end

      if word.nil?
        UI.puts UI.red("No words found for this mode!")
        async_sleep 2
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
        when :digraph
          @trainer.random_digraph_word
        when :trigraph
          @trainer.random_trigraph_word
        when :vowel_cluster
          @trainer.random_vowel_cluster_word
        when :consonant_blend
          @trainer.random_consonant_blend_word
        end
        
        result = play_round(word)
        
        if result == :solved
          streak_result = @trainer.record_result(true)
          if streak_result == :level_up
            UI.puts UI.bold(UI.yellow("\n*** LEVEL UP! Increasing word length! ***"))
            async_sleep 2
          end
        elsif result == :esc
          @trainer.record_result(false)
          break
        end
        
        # Move to next word (already pre-fetched)
        
        word = next_word
        
        # Check if we ran out of words
        if word.nil?
          UI.puts UI.red("No more words found for this mode!")
          async_sleep 2
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
      require 'json'
      require 'js' if defined?(JS)

      JS.global[:console].call(:log, "RUBY_PLATFORM: #{RUBY_PLATFORM}") if defined?(JS)

      if RUBY_PLATFORM.include?('wasi')
        require 'js'
        JS.global[:console].call(:log, "get_definition: Using WASM/JS fetch path for: #{word}")
        begin
          promise = JS.global.fetch("https://api.dictionaryapi.dev/api/v2/entries/en/#{word}")
          response = promise.await
          
          if response[:ok]
            json_promise = response.json
            json_obj = json_promise.await
            json_str = JS.global[:JSON].stringify(json_obj).to_s
            data = JSON.parse(json_str)
            
            if data.is_a?(Array) && data.first && data.first['meanings']
              first_meaning = data.first['meanings'].first
              if first_meaning && first_meaning['definitions'] && first_meaning['definitions'].first
                return first_meaning['definitions'].first['definition']
              end
            end
          end
          return "Definition not found."
        rescue => e
          return "Definition unavailable: #{e.message}"
        end
      else
        # Native Ruby - use net/http
        require 'js' if RUBY_PLATFORM.include?('wasi')
        JS.global[:console].call(:log, "get_definition: Using native Ruby net/http path") if RUBY_PLATFORM.include?('wasi')
        require 'net/http'
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
          "Definition not available."
        end
      end
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
