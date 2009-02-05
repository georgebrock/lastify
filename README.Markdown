# Lastify

A SIMBL plugin that adds Last.fm Love and Ban capabilities to Spotify.
It works enough to be useable, but it's a long way from perfect.

### Done

* Working SIMBL plugin
* Simple GUI
* Authentication with Last.fm
* "Love track" Last.fm API call
* "Ban track" Last.fm API call
* Tracking of what's currently playing in Spotify
* Store authentication tokens in keychain
* Last.fm HTTP or API errors no longer crash Spotify

### Still to do

* Handle specific errors from Last.fm API (e.g. expired auth tokens should be automatically removed from the KeyChain and re-requested from Last.fm)
