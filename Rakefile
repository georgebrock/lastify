require 'rexml/document'

module Spotify
  def self.path
    '/Applications/Spotify.app'
  end

  def self.bundle_version
    plist_value :CFBundleVersion
  end

  def self.version
    plist_value :CFBundleShortVersionString
  end

  def self.plist_value(key)
    @spotify_plist ||= REXML::Document.new(File.new("#{path}/Contents/Info.plist"))
    REXML::XPath.match(@spotify_plist, %Q{//key[text()="#{key.to_s}"]/following-sibling::string[1]}).pop.text
  end
end

desc 'Update the SIMBL maximum bundle version to the current version of Spotify'
task :update do
  lastify_plist = REXML::Document.new(File.new('Info.plist'))
  array_node = REXML::XPath.match(lastify_plist, '//key[text()="SIMBLTargetApplications"]/following-sibling::array[1]')
  max_version_node = REXML::XPath.match(array_node, '//key[text()="MaxBundleVersion"]/following-sibling::string[1]').pop
  max_version_node.text = Spotify.bundle_version
  File.open('Info.plist', 'w') {|f| f.write(lastify_plist) }

  puts "\nVersion updated to #{Spotify.version} (#{Spotify.bundle_version})"
end

desc 'Recompile the plugin and restart Spotify'
task :build do
  system 'xcodebuild'
end

namespace :spotify do
  desc "Outputs the current Spotify version"
  task :version do
    puts "#{Spotify.version} (#{Spotify.bundle_version})"
  end

  task :restart do
    system 'killall', 'Spotify'
    system 'open', Spotify.path
  end
end

desc 'Runs the "update", "build" and "spotify:restart" tasks'
task :update_and_build => [:update, :build, :'spotify:restart']

task :default => :update_and_build
