{Robot, Adapter, TextMessage} = require 'hubot'
splitStrings = require './split_strings'
crypto = require 'crypto'

MESSAGE_LENGTH_MAX = 1000

class Lingr extends Adapter
  send: (envelope, strings...) ->
    partStrings = splitStrings(strings, MESSAGE_LENGTH_MAX)
    fire = =>
      if partStrings.length != 0
        str = partStrings.shift()
        @sendPart(envelope.room, str, fire)
    fire()

  sendPart: (room, string, cb) ->
    query =
      room: room
      bot: @name
      text: string
      bot_verifier: crypto.createHash('sha1').update(@name + @secret).digest('hex')

    @robot.http("http://lingr.com")
      .path("/api/room/say")
      .query(query)
      .get() (err, res, body) ->
        console.log body
        cb?()

  reply: (envelope, strings...) ->
    for str in strings
      @send envelope.user, "@#{envelope.user.name}: #{str}"

  run: ->
    self = @

    @name   = process.env.HUBOT_LINGR_BOT
    @secret = process.env.HUBOT_LINGR_SECRET
    @endpoint = process.env.HUBOT_LINGR_ENDPOINT || "/hubot/lingr"

    @robot.router.post @endpoint, (request, response) =>
      @processEvent event for event in request.body.events
      response.writeHead 200, 'Content-Type': 'text/plain'
      response.end()

    self.emit "connected"

  processEvent: (event) ->
    switch event.message?.type
      when "user"
        re = new RegExp('@' + @robot.name, 'i')
        text = event.message.text.replace re, @robot.name
        author =
          speaker_id: event.message.speaker_id
          event_id: event.message.event_id
        message = new TextMessage(author, text)
        message.room = event.message.room
        @receive message
    # TODO support enter/leave

exports.use = (robot) ->
  new Lingr robot
