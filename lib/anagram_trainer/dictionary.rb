module AnagramTrainer
  class Dictionary
    def initialize(path)
      @words = File.readlines(path).map(&:strip).reject(&:empty?)
      @dict_dir = File.dirname(path)
      
      # Load pre-computed filtered lists if available
      load_filtered_lists
    end

    def random_word(min_length: 5, max_length: nil)
      filter_words(min_length: min_length, max_length: max_length).sample
    end

    def filter_by_suffix(suffixes)
      # Use pre-computed list if available
      return @suffix_words if @suffix_words
      
      # Fallback to on-the-fly filtering
      @words.select do |w|
        suffixes.any? do |s|
          suffix_lower = s.downcase
          if w.end_with?(suffix_lower)
            # Check if the root word (without suffix) exists in dictionary
            root = w[0...-suffix_lower.length]
            word_exists?(root)
          else
            false
          end
        end
      end
    end

    def filter_by_prefix(prefixes)
      # Use pre-computed list if available
      return @prefix_words if @prefix_words
      
      # Fallback to on-the-fly filtering
      @words.select do |w|
        prefixes.any? do |p|
          prefix_lower = p.downcase
          if w.start_with?(prefix_lower)
            # Check if the root word (without prefix) exists in dictionary
            root = w[prefix_lower.length..]
            word_exists?(root)
          else
            false
          end
        end
      end
    end

    def word_exists?(word)
      @words.include?(word.downcase)
    end

    private
    
    def load_filtered_lists
      suffix_file = File.join(@dict_dir, 'suffix_words.txt')
      prefix_file = File.join(@dict_dir, 'prefix_words.txt')
      
      if File.exist?(suffix_file)
        @suffix_words = File.readlines(suffix_file).map(&:strip).reject(&:empty?)
      end
      
      if File.exist?(prefix_file)
        @prefix_words = File.readlines(prefix_file).map(&:strip).reject(&:empty?)
      end
    end

    def filter_words(min_length: nil, max_length: nil)
      @words.select do |w| 
        (min_length.nil? || w.length >= min_length) && 
        (max_length.nil? || w.length <= max_length)
      end
    end
  end
end
