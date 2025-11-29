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
      if RUBY_PLATFORM.include?('wasi')
        require 'js'
        stored_data = JS.global[:localStorage].getItem('anagram_trainer_history')
        return [] if stored_data == JS::Null || stored_data.to_s.empty?
        JSON.parse(stored_data.to_s, symbolize_names: true)
      else
        return [] unless File.exist?(@path)
        begin
          JSON.parse(File.read(@path), symbolize_names: true)
        rescue JSON::ParserError
          []
        end
      end
    end

    def save_history
      if RUBY_PLATFORM.include?('wasi')
        require 'js'
        json_str = JSON.generate(@history)
        JS.global[:localStorage].setItem('anagram_trainer_history', json_str)
      else
        File.write(@path, JSON.pretty_generate(@history))
      end
    end

    public

    def save_campaign_progress(stage_index, score)
      data = { stage_index: stage_index, score: score }
      if RUBY_PLATFORM.include?('wasi')
        require 'js'
        JS.global[:localStorage].setItem('anagram_trainer_campaign', JSON.generate(data))
      else
        path = File.join(File.dirname(@path), 'campaign.json')
        File.write(path, JSON.generate(data))
      end
    end

    def load_campaign_progress
      if RUBY_PLATFORM.include?('wasi')
        require 'js'
        stored = JS.global[:localStorage].getItem('anagram_trainer_campaign')
        return nil if stored == JS::Null || stored.to_s.empty?
        JSON.parse(stored.to_s, symbolize_names: true)
      else
        path = File.join(File.dirname(@path), 'campaign.json')
        return nil unless File.exist?(path)
        JSON.parse(File.read(path), symbolize_names: true)
      end
    rescue
      nil
    end

    def save_leaderboard_entry(name, score)
      leaderboard = get_leaderboard
      leaderboard << { name: name, score: score, date: Time.now.to_s }
      leaderboard.sort_by! { |entry| -entry[:score] }
      leaderboard = leaderboard.take(10) # Keep top 10
      
      if RUBY_PLATFORM.include?('wasi')
        require 'js'
        JS.global[:localStorage].setItem('anagram_trainer_leaderboard', JSON.generate(leaderboard))
      else
        path = File.join(File.dirname(@path), 'leaderboard.json')
        File.write(path, JSON.pretty_generate(leaderboard))
      end
    end

    def get_leaderboard
      if RUBY_PLATFORM.include?('wasi')
        require 'js'
        stored = JS.global[:localStorage].getItem('anagram_trainer_leaderboard')
        return [] if stored == JS::Null || stored.to_s.empty?
        JSON.parse(stored.to_s, symbolize_names: true)
      else
        path = File.join(File.dirname(@path), 'leaderboard.json')
        return [] unless File.exist?(path)
        JSON.parse(File.read(path), symbolize_names: true)
      end
    rescue
      []
    end
  end
end
