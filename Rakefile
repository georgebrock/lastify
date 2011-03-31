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

desc 'Recompile the plugin'
task :build do
  system 'xcodebuild'
end

desc 'Creates a ZIP file of the current build'
task :package do
  Dir.chdir 'build/Release'
  system 'zip', '-r', "lastify-#{Spotify.version}.zip", 'Lastify.bundle'
end

desc 'Uploads a ZIP file of the current build to Github'
task :upload do
  begin
    require 'net/github-upload'
  rescue LoadError
    raise 'Please run `gem install net-github-upload` to continue'
  end

  login, token = ['github.user', 'github.token'].map{|key| `git config #{key}`.chomp }
  github = Net::GitHub::Upload.new(:login => login, :token => token)
  github.upload(:repos => 'lastify', :file => "build/Release/lastify-#{Spotify.version}.zip", :description => "for Spotify #{Spotify.version}")
end

namespace :spotify do
  desc "Outputs the current Spotify version"
  task :version do
    puts "#{Spotify.version} (#{Spotify.bundle_version})"
  end

  desc 'Restart Spotify'
  task :restart do
    system 'killall', 'Spotify'
    system 'open', Spotify.path
  end
end

desc 'Runs the "update", "build" and "spotify:restart" tasks'
task :update_and_build => [:update, :build, :'spotify:restart']

task :default => :update_and_build
