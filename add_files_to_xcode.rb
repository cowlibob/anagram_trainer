require 'xcodeproj'

project_path = 'ios/AnagramTrainer/AnagramTrainer.xcodeproj'
project = Xcodeproj::Project.open(project_path)

group_name = 'Views'
components_group_name = 'Components'

# Find or create Views group
views_group = project.main_group.find_subpath(File.join('AnagramTrainer', group_name), true)

# Find or create Components group
components_group = views_group.find_subpath(components_group_name, true)
components_group.set_source_tree('<group>')
components_group.set_path('Components')

# Files to add
files = [
  'LetterButtonView.swift',
  'ScrambledWordView.swift',
  'GuessView.swift',
  'TimerView.swift',
  'CursorView.swift',
  'GameResultView.swift',
  'CampaignResultView.swift',
  'CampaignCompleteView.swift',
  'LeaderboardEntrySheet.swift',
  'CampaignGameView.swift'
]

target = project.targets.first

files.each do |file|
  file_path = File.join('Components', file)
  # Check if file is already in the group to avoid duplicates
  unless components_group.find_file_by_path(file)
    file_ref = components_group.new_reference(file)
    target.add_file_references([file_ref])
    puts "Added #{file} to project"
  else
    puts "#{file} already exists in project"
  end
end

project.save
puts "Project saved!"
