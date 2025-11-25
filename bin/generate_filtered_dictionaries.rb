#!/usr/bin/env ruby
# Script to generate pre-filtered word lists for suffix and prefix training
# Uses threading to speed up processing

require 'set'
require 'thread'

# Load dictionary
DICT_PATH = File.join(__dir__, '..', 'data', 'dictionary.txt')
words = File.readlines(DICT_PATH).map(&:strip).reject(&:empty?)
word_set = Set.new(words)

SUFFIXES = %w[ing tion ness able ment ized]
PREFIXES = %w[un re pre dis over out]

puts "Loaded #{words.length} words from dictionary"
puts "Using #{[SUFFIXES.length, PREFIXES.length].max} threads for processing"

# Thread-safe arrays
suffix_words = []
prefix_words = []
mutex = Mutex.new

# Process suffix words
puts "\nProcessing suffix words..."
suffix_threads = SUFFIXES.map do |suffix|
  Thread.new do
    local_results = []
    suffix_lower = suffix.downcase
    
    words.each do |word|
      if word.end_with?(suffix_lower)
        root = word[0...-suffix_lower.length]
        if word_set.include?(root.downcase)
          local_results << word
        end
      end
    end
    
    # Add to shared array with mutex
    mutex.synchronize do
      suffix_words.concat(local_results)
      puts "  Found #{local_results.length} words for suffix '#{suffix}'"
    end
  end
end

suffix_threads.each(&:join)
suffix_words.uniq!
puts "Total suffix words: #{suffix_words.length}"

# Process prefix words
puts "\nProcessing prefix words..."
prefix_threads = PREFIXES.map do |prefix|
  Thread.new do
    local_results = []
    prefix_lower = prefix.downcase
    
    words.each do |word|
      if word.start_with?(prefix_lower)
        root = word[prefix_lower.length..]
        if word_set.include?(root.downcase)
          local_results << word
        end
      end
    end
    
    # Add to shared array with mutex
    mutex.synchronize do
      prefix_words.concat(local_results)
      puts "  Found #{local_results.length} words for prefix '#{prefix}'"
    end
  end
end

prefix_threads.each(&:join)
prefix_words.uniq!
puts "Total prefix words: #{prefix_words.length}"

# Write results
SUFFIX_OUTPUT = File.join(__dir__, '..', 'data', 'suffix_words.txt')
PREFIX_OUTPUT = File.join(__dir__, '..', 'data', 'prefix_words.txt')

puts "\nWriting results..."
File.write(SUFFIX_OUTPUT, suffix_words.sort.join("\n"))
puts "Wrote #{suffix_words.length} words to #{SUFFIX_OUTPUT}"

File.write(PREFIX_OUTPUT, prefix_words.sort.join("\n"))
puts "Wrote #{prefix_words.length} words to #{PREFIX_OUTPUT}"

puts "\nDone!"
