#!/usr/bin/env ruby
# Script to build a dictionary from EOWL (The English Open Word List)
# Concatenates A-Z files from "EOWL LF Delimited Format" and filters by length.

require 'fileutils'

SOURCE_DIR = File.join(__dir__, '..', 'external', 'EOWL', 'EOWL LF Delimited Format')
OUTPUT_FILE = File.join(__dir__, '..', 'data', 'dictionary.txt')
MIN_LENGTH = 5

unless Dir.exist?(SOURCE_DIR)
  puts "Error: EOWL source directory not found at #{SOURCE_DIR}"
  puts "Make sure to run 'git submodule update --init' if you haven't already."
  exit 1
end

words = []

# Process all LF Delimited Format files (A-Z)
Dir.glob(File.join(SOURCE_DIR, '* Words.txt')).sort.each do |file|
  puts "Processing #{File.basename(file)}..."
  File.readlines(file).each do |line|
    word = line.strip
    next if word.empty?
    
    # Filter by minimum length
    if word.length >= MIN_LENGTH
      words << word.downcase
    end
  end
end

# Sort and unique
words = words.uniq.sort

puts "Found #{words.length} words with length >= #{MIN_LENGTH}"

# Write to output file
File.write(OUTPUT_FILE, words.join("\n") + "\n")
puts "Wrote results to #{OUTPUT_FILE}"
