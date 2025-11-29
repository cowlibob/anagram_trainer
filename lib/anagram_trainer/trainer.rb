module AnagramTrainer
  class Trainer
    SUFFIXES = %w[ing tion ness able ment ized]
    PREFIXES = %w[un re pre dis over out]
    DIGRAPHS = %w[th sh ch ph wh]
    TRIGRAPHS = %w[str thr shr tch dge]
    VOWEL_CLUSTERS = %w[ie ea ou ee oo]
    CONSONANT_BLENDS = %w[st bl br cl fl]

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

    def random_digraph_word
      words = @dictionary.filter_by_digraph(DIGRAPHS)
      pick_graduated_word(words)
    end

    def random_trigraph_word
      words = @dictionary.filter_by_trigraph(TRIGRAPHS)
      pick_graduated_word(words)
    end

    def random_vowel_cluster_word
      words = @dictionary.filter_by_vowel_cluster(VOWEL_CLUSTERS)
      pick_graduated_word(words)
    end

    def random_consonant_blend_word
      words = @dictionary.filter_by_consonant_blend(CONSONANT_BLENDS)
      pick_graduated_word(words)
    end

    def hints(mode)
      case mode
      when :suffix then SUFFIXES
      when :prefix then PREFIXES
      when :digraph then DIGRAPHS
      when :trigraph then TRIGRAPHS
      when :vowel_cluster then VOWEL_CLUSTERS
      when :consonant_blend then CONSONANT_BLENDS
      else []
      end
    end

    def set_level(level)
      @current_length = level.clamp(5, 9)
      save_level
    end

    # --- Campaign Logic ---

    CAMPAIGN_STAGES = [
      { name: "Warm Up", mode: :graduated, length: 5, count: 5 },
      { name: "Suffixes", mode: :suffix, count: 5 },
      { name: "Prefixes", mode: :prefix, count: 5 },
      { name: "Digraphs", mode: :digraph, count: 5 },
      { name: "Vowel Clusters", mode: :vowel_cluster, count: 5 },
      { name: "Consonant Blends", mode: :consonant_blend, count: 5 },
      { name: "Trigraphs", mode: :trigraph, count: 5 },
      { name: "Boss Level", mode: :graduated, length: 6, count: 10 }
    ]

    class Campaign
      attr_reader :stage_index, :score, :words_remaining

      def initialize(trainer, start_stage: 0, start_score: 0)
        @trainer = trainer
        @stage_index = start_stage
        @score = start_score
        reset_stage_progress
      end

      def current_stage
        CAMPAIGN_STAGES[@stage_index]
      end

      def completed?
        @stage_index >= CAMPAIGN_STAGES.length
      end

      def next_word
        return nil if completed?
        
        stage = current_stage
        if stage[:length]
          @trainer.set_level(stage[:length])
        end
        
        case stage[:mode]
        when :graduated then @trainer.next_graduated_word
        when :suffix then @trainer.random_suffix_word
        when :prefix then @trainer.random_prefix_word
        when :digraph then @trainer.random_digraph_word
        when :trigraph then @trainer.random_trigraph_word
        when :vowel_cluster then @trainer.random_vowel_cluster_word
        when :consonant_blend then @trainer.random_consonant_blend_word
        end
      end

      def record_success(time_taken)
        # Base score: 100
        # Time bonus: max(0, (10 - time) * 10)
        base_score = 100
        time_bonus = [0, (15 - time_taken) * 10].max.to_i
        points = base_score + time_bonus
        
        @score += points
        @words_remaining -= 1
        
        stage_complete = @words_remaining <= 0
        if stage_complete
          @stage_index += 1
          reset_stage_progress unless completed?
        end
        
        { points: points, stage_complete: stage_complete, campaign_complete: completed? }
      end

      private

      def reset_stage_progress
        return if completed?
        @words_remaining = current_stage[:count]
      end
    end

    def start_campaign(start_stage: 0, start_score: 0)
      Campaign.new(self, start_stage: start_stage, start_score: start_score)
    end

    private

    def save_level
      return unless @level_file
      if RUBY_PLATFORM.include?('wasi')
        require 'js'
        JS.global[:localStorage].setItem('anagram_trainer_level', @current_length.to_s)
      else
        File.write(@level_file, @current_length.to_s)
      end
    rescue
      # Silently fail if we can't save
    end

    def load_level
      if RUBY_PLATFORM.include?('wasi')
        require 'js'
        stored_level = JS.global[:localStorage].getItem('anagram_trainer_level')
        return nil if stored_level == JS::Null || stored_level.to_s.empty?
        stored_level.to_s.to_i
      else
        return nil unless @level_file && File.exist?(@level_file)
        File.read(@level_file).strip.to_i
      end
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
