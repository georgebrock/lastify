# Lastify

A SIMBL plugin that adds Last.fm Love, Ban and Tagging capabilities to Spotify.
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
* Tagging interface

### Still to do

* Handle specific errors from Last.fm API (e.g. expired auth tokens should be automatically removed from the KeyChain and re-requested from Last.fm)
* Re-work authentication GUI to walk the user through things a bit more

### Attribution

Lastify uses the famfamfam Silk icon set. See [famfamfam.com](http://www.famfamfam.com/lab/icons/silk/) for more information.
