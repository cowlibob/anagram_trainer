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
DIGRAPHS = %w[th sh ch ph wh]
TRIGRAPHS = %w[str thr shr tch dge]
VOWEL_CLUSTERS = %w[ie ea ou ee oo]
CONSONANT_BLENDS = %w[st bl br cl fl]

puts "Loaded #{words.length} words from dictionary"
puts "Using #{[SUFFIXES.length, PREFIXES.length, DIGRAPHS.length, TRIGRAPHS.length, VOWEL_CLUSTERS.length, CONSONANT_BLENDS.length].max} threads for processing"

# Thread-safe arrays
suffix_words = []
prefix_words = []
digraph_words = []
trigraph_words = []
vowel_cluster_words = []
consonant_blend_words = []
mutex = Mutex.new

# Helper to process a list of patterns
process_patterns = ->(patterns, target_array, name, type) do
  puts "\nProcessing #{name}..."
  threads = patterns.map do |pattern|
    Thread.new do
      local_results = []
      pattern_lower = pattern.downcase
      
      words.each do |word|
        if word.downcase.include?(pattern_lower)
          # For these internal clusters, we just check if the word contains it.
          # We don't strictly strip it to check for a root word like we do for prefix/suffix
          # because these can appear anywhere.
          # However, to be safe and ensure it's a valid word context, we just check existence.
          # But wait, for prefix/suffix we checked if the *remainder* was a word.
          # For these, we just want words containing the pattern.
          local_results << word
        end
      end
      
      # Add to shared array with mutex
      mutex.synchronize do
        target_array.concat(local_results)
        puts "  Found #{local_results.length} words for #{type} '#{pattern}'"
      end
    end
  end
  threads.each(&:join)
  target_array.uniq!
  puts "Total #{name}: #{target_array.length}"
end

# Process suffix words (special logic: end_with?)
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
    
    mutex.synchronize do
      suffix_words.concat(local_results)
      puts "  Found #{local_results.length} words for suffix '#{suffix}'"
    end
  end
end
suffix_threads.each(&:join)
suffix_words.uniq!
puts "Total suffix words: #{suffix_words.length}"

# Process prefix words (special logic: start_with?)
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
    
    mutex.synchronize do
      prefix_words.concat(local_results)
      puts "  Found #{local_results.length} words for prefix '#{prefix}'"
    end
  end
end
prefix_threads.each(&:join)
prefix_words.uniq!
puts "Total prefix words: #{prefix_words.length}"

# Process new clusters
process_patterns.call(DIGRAPHS, digraph_words, "digraph words", "digraph")
process_patterns.call(TRIGRAPHS, trigraph_words, "trigraph words", "trigraph")
process_patterns.call(VOWEL_CLUSTERS, vowel_cluster_words, "vowel cluster words", "cluster")
process_patterns.call(CONSONANT_BLENDS, consonant_blend_words, "consonant blend words", "blend")

# Write results
SUFFIX_OUTPUT = File.join(__dir__, '..', 'data', 'suffix_words.txt')
PREFIX_OUTPUT = File.join(__dir__, '..', 'data', 'prefix_words.txt')
DIGRAPH_OUTPUT = File.join(__dir__, '..', 'data', 'digraph_words.txt')
TRIGRAPH_OUTPUT = File.join(__dir__, '..', 'data', 'trigraph_words.txt')
VOWEL_CLUSTER_OUTPUT = File.join(__dir__, '..', 'data', 'vowel_cluster_words.txt')
CONSONANT_BLEND_OUTPUT = File.join(__dir__, '..', 'data', 'consonant_blend_words.txt')

puts "\nWriting results..."
File.write(SUFFIX_OUTPUT, suffix_words.sort.join("\n"))
puts "Wrote #{suffix_words.length} words to #{SUFFIX_OUTPUT}"

File.write(PREFIX_OUTPUT, prefix_words.sort.join("\n"))
puts "Wrote #{prefix_words.length} words to #{PREFIX_OUTPUT}"

File.write(DIGRAPH_OUTPUT, digraph_words.sort.join("\n"))
puts "Wrote #{digraph_words.length} words to #{DIGRAPH_OUTPUT}"

File.write(TRIGRAPH_OUTPUT, trigraph_words.sort.join("\n"))
puts "Wrote #{trigraph_words.length} words to #{TRIGRAPH_OUTPUT}"

File.write(VOWEL_CLUSTER_OUTPUT, vowel_cluster_words.sort.join("\n"))
puts "Wrote #{vowel_cluster_words.length} words to #{VOWEL_CLUSTER_OUTPUT}"

File.write(CONSONANT_BLEND_OUTPUT, consonant_blend_words.sort.join("\n"))
puts "Wrote #{consonant_blend_words.length} words to #{CONSONANT_BLEND_OUTPUT}"

puts "\nDone!"
