module AnagramTrainer
  class Trainer
    SUFFIXES = %w[ing tion ness able ment ized]
    PREFIXES = %w[un re pre dis over out]

    def initialize(dictionary, level_file = nil)
      @dictionary = dictionary
      @level_file = level_file
      @current_length = load_level || 5
      @streak = 0
    end

    def next_graduated_word
      word = @dictionary.random_word(min_length: @current_length, max_length: @current_length)
      # Fallback if no word found (shouldn't happen with standard dict but good safety)
      word || @dictionary.random_word(min_length: 5)
    end

    def record_result(solved)
      if solved
        @streak += 1
        if @streak >= 3 && @current_length < 9
          @current_length += 1
          @streak = 0
          save_level
          return :level_up
        end
      else
        @streak = 0
      end
      nil
    end

    def current_level
      @current_length
    end

    def random_suffix_word
      words = @dictionary.filter_by_suffix(SUFFIXES)
      pick_graduated_word(words)
    end

    def random_prefix_word
      words = @dictionary.filter_by_prefix(PREFIXES)
      pick_graduated_word(words)
    end

    def set_level(level)
      @current_length = level.clamp(5, 9)
      save_level
    end

    private

    def save_level
      return unless @level_file
      File.write(@level_file, @current_length.to_s)
    rescue
      # Silently fail if we can't save
    end

    def load_level
      return nil unless @level_file && File.exist?(@level_file)
      File.read(@level_file).strip.to_i
    rescue
      nil
    end

    def pick_graduated_word(candidates)
      # Filter for words at least as long as current level
      valid_candidates = candidates.select { |w| w.length >= @current_length }
      
      # If no words match current level (unlikely but possible), fallback to any
      return candidates.sample if valid_candidates.empty?

      # Group by length to find the shortest available length
      min_available_length = valid_candidates.map(&:length).min
      
      # Pick from the shortest available length bucket
      # This ensures we don't jump to 10-letter words if 5-letter ones exist
      valid_candidates.select { |w| w.length == min_available_length }.sample
    end
  end
end
