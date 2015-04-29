# Description
#   Displays information when Beatport songs are linked.
#
# Commands:
#   None
#
# Notes:
#   Just link a www.beatport.com sound and we'll do the rest.
#
# Author:
#   Jeremy Mack @mutewinter

_ = require 'lodash'

beatportRegex = ///
  (?:https?://              # authority
  (?:www\.)?beatport\.com/) # domain
  (?:\w+)/                  # owner
  (?:tracks|mixes)/         # type
  ([\d\w]+)                 # sound id
///i

module.exports = (robot) ->
  robot.hear beatportRegex, (msg) ->
    soundId = msg.match[1]
    msg.http("https://apix.beatport.com/sounds/#{soundId}")
      .get() (error, response, body) ->
        return msg.send "Encountered an error :( #{error}" if error
        sound = JSON.parse(body)
        if sound.artists
          artists = sound.artists.map (artist) -> artist.display_name
          artists = artists.join(', ')

        nameParts = [
          sound.name
          "(#{sound.mix_name})" if sound.name
          '-'
          artists if artists
        ]
        nameParts = _.compact(nameParts)
        msg.send ":beatport: #{nameParts.join(' ')}"
