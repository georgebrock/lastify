task :update_spotify_version do
  require 'rexml/document'
  include REXML

  system "killall Spotify"

  spotify_plist = REXML::Document.new(File.new('/Applications/Spotify.app/Contents/Info.plist'))
  new_version = REXML::XPath.match(spotify_plist, '//key[text()="CFBundleVersion"]/following-sibling::string[1]').pop.text

  lastify_plist = REXML::Document.new(File.new('Info.plist'))
  array_node = REXML::XPath.match(lastify_plist, '//key[text()="SIMBLTargetApplications"]/following-sibling::array[1]')
  max_version_node = REXML::XPath.match(array_node, '//key[text()="MaxBundleVersion"]/following-sibling::string[1]').pop
  max_version_node.text = new_version
  File.open('Info.plist', 'w') {|f| f.write(doc) }

  puts "Version updated to #{new_version}"

  system "xcodebuild"
  system "open /Applications/Spotify.app"
end

task :default => :update_spotify_version
