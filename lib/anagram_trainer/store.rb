require "json"

module AnagramTrainer
  class Store
    attr_reader :history

    def initialize(path)
      @path = path
      @history = load_history
    end

    def add_attempt(word, time_taken, solved, attempts = 0)
      @history << {
        word: word,
        time_taken: time_taken,
        solved: solved,
        attempts: attempts,
        timestamp: Time.now.to_s
      }
      save_history
    end

    def average_time
      solved_attempts = @history.select { |h| h[:solved] }
      return 0 if solved_attempts.empty?

      total_time = solved_attempts.sum { |h| h[:time_taken] }
      total_time / solved_attempts.size
    end

    def total_solved
      @history.count { |h| h[:solved] }
    end

    private

    def load_history
      return [] unless File.exist?(@path)

      begin
        JSON.parse(File.read(@path), symbolize_names: true)
      rescue JSON::ParserError
        []
      end
    end

    def save_history
      File.write(@path, JSON.pretty_generate(@history))
    end
  end
end
