
https = require 'https'

room_id = process.env.HUBOT_GROUPME_ROOM_ID
bot_id = process.env.HUBOT_GROUPME_BOT_ID
token = process.env.HUBOT_GROUPME_TOKEN

module.exports = (robot) ->
  blacklist = []

  saveBlacklist = () ->
    console.log 'Saving blacklist'
    robot.brain.set 'blacklist', blacklist
    robot.brain.save()

  loadBlacklist = () ->
    blacklist = robot.brain.get 'blacklist'
    if blacklist
      console.log 'Blacklist loaded successfully'
    else
      console.warn 'Blacklist failed to load'

  addToBlacklist = (item) ->
    blacklist.push item
    saveBlacklist()

  removeFromBlacklist = (item) ->
    index = blacklist.indexOf item
    console.log "Found #{item} at #{index}"
    if index != -1
      blacklist.splice index, 1
      saveBlacklist()
    else
      console.warn "Unable to find #{item}"

  getUserByName = (name) ->
    name = name.trim()
    if name[0] == "@"
      name = name.slice 1
    user = robot.brain.userForName name
    unless user.user_id
      return null
    user

  getUserById = (id) ->
    user = robot.brain.userForId id
    unless user.user_id
      return null
    user

  robot.brain.once 'loaded', () ->
    loadBlacklist()

  robot.hear /get id (.*)/i, (res) ->
    """Get ID command"""
    target = res.match[1]
    console.log "Looking for user ID by name: #{target}"
    found = getUserByName target
    if found
      found = found.user_id
      console.log "Found ID #{found} by using #{target}"
      res.send "#{target}: #{found}"
    else
      res.send "Could not find a user with the name #{target}"

  robot.hear /get name (.*)/i, (res) ->
    """Get name command"""
    target = res.match[1]
    console.log "Looking for user name by ID: #{target}"
    found = getUserById target
    if found
      found = found.name
      console.log "Found name #{found} by using #{target}"
      res.send "#{target}: #{found}"
    else
      res.send "Could not find a user with the ID #{target}"

  robot.hear /view( raw)? blacklist/i, (res) ->
    """View blacklist command"""
    if res.match[1]
      # If raw output desired
      res.send JSON.stringify blacklist
    else
      blacklistNames = []
      for item in blacklist
        user = getUserById item
        if user
          blacklistNames.push user.name
      if blacklistNames.length > 0
        res.send blacklistNames.join ', '
      else
        res.send "There are currently no users blacklisted."

  robot.hear /blacklist (.*)/i, (res) ->
    """Blacklist command (expects name)"""
    target = res.match[1]
    user = getUserByName target
    if user
      console.log "Blacklisting #{target}"
      addToBlacklist user.user_id
      res.send "Blacklisted #{target} successfully"
    else
      res.send "Could not find a user by the name #{target}"

  robot.hear /whitelist (.*)/i, (res) ->
    """Whitelist command (expects name)"""
    target = res.match[1]
    user = getUserByName target
    if user
      console.log "Whitelisting #{target}"
      removeFromBlacklist user.user_id
      res.send "Whitelisted #{target} successfully"
    else
      res.send "Could not find a user by the name #{target}"
  
  robot.hear /\/skateSpots/i, (res) ->
    """@all command"""
    text = res.match[0]

    messageONE =
      'text': "Park #1",
      'bot_id': bot_id,
      'attachments': [
          {
            "type": "location",
            "lat": "30.6441",
            "lng": "-96.3648",
            "name": "Williamshlong"
          }
      ]

    messageTWO =
      'text': "Park #2",
      'bot_id': bot_id,
      'attachments': [
          {
            "type": "location",
            "lat": "30.580408",
            "lng": "-96.293922",
            "name": "Cock-Prairie"
          }
      ]
    
    messageTHREE =
      'text': "Spot #3",
      'bot_id': bot_id,
      'attachments': [
          {
            "type": "location",
            "lat": "30.6172",
            "lng": "-96.3438",
            "name": "Sbisa"
          }
      ]

    messageFOUR =
      'text': "Spot #4",
      'bot_id': bot_id,
      'attachments': [
          {
            "type": "location",
            "lat": "30.615981",
            "lng": "-96.345147",
            "name": "The Courts"
          }
      ]

    jsonONE = JSON.stringify(messageONE)
    jsonTWO = JSON.stringify(messageTWO)
    jsonTHREE = JSON.stringify(messageTHREE)
    jsonFOUR = JSON.stringify(messageFOUR)

    optionsONE =
      agent: false
      host: "api.groupme.com"
      path: "/v3/bots/post"
      port: 443
      method: "POST"
      headers:
        'Content-Length': jsonONE.length
        'Content-Type': 'application/json'
        'X-Access-Token': token

    optionsTWO =
      agent: false
      host: "api.groupme.com"
      path: "/v3/bots/post"
      port: 443
      method: "POST"
      headers:
        'Content-Length': jsonTWO.length
        'Content-Type': 'application/json'
        'X-Access-Token': token
    
    optionsTHREE =
      agent: false
      host: "api.groupme.com"
      path: "/v3/bots/post"
      port: 443
      method: "POST"
      headers:
        'Content-Length': jsonTHREE.length
        'Content-Type': 'application/json'
        'X-Access-Token': token

    optionsFOUR =
      agent: false
      host: "api.groupme.com"
      path: "/v3/bots/post"
      port: 443
      method: "POST"
      headers:
        'Content-Length': jsonFOUR.length
        'Content-Type': 'application/json'
        'X-Access-Token': token


    req = https.request optionsFOUR, (response) ->
      data = ''
      response.on 'data', (chunk) -> data += chunk
      response.on 'end', ->
        console.log "[GROUPME RESPONSE] #{response.statusCode} #{data}"
    req.end(jsonFOUR)

    req = https.request optionsTHREE, (response) ->
      data = ''
      response.on 'data', (chunk) -> data += chunk
      response.on 'end', ->
        console.log "[GROUPME RESPONSE] #{response.statusCode} #{data}"
    req.end(jsonTHREE)
    
    req = https.request optionsTWO, (response) ->
      data = ''
      response.on 'data', (chunk) -> data += chunk
      response.on 'end', ->
        console.log "[GROUPME RESPONSE] #{response.statusCode} #{data}"
    req.end(jsonTWO)

    req = https.request optionsONE, (response) ->
      data = ''
      response.on 'data', (chunk) -> data += chunk
      response.on 'end', ->
        console.log "[GROUPME RESPONSE] #{response.statusCode} #{data}"
    req.end(jsonONE)

  robot.hear /\/help/i, (res) ->
    res.send "Here are things you can do:" + "\n\t" + "1. Type @all to mention everyone" + "\n\t" + "2. Type /skateSpots to get locations of usual skate spots around town."

  robot.hear /(.*)@all(.*)/i, (res) ->
    """@all command"""
    text = res.match[0]
    users = robot.brain.users()

    if text.length < users.length
      text = "Please check the GroupMe, everyone."

    message =
      'text': text,
      'bot_id': bot_id,
      'attachments': [
        "loci": [],
        "type": "mentions",
        "user_ids": []
      ]

    i = 0
    for user, values of users
      if user in blacklist
        continue
      message.attachments[0].loci.push([i, i+1])
      message.attachments[0].user_ids.push(user)
      i += 1

    json = JSON.stringify(message)

    options =
      agent: false
      host: "api.groupme.com"
      path: "/v3/bots/post"
      port: 443
      method: "POST"
      headers:
        'Content-Length': json.length
        'Content-Type': 'application/json'
        'X-Access-Token': token

    req = https.request options, (response) ->
      data = ''
      response.on 'data', (chunk) -> data += chunk
      response.on 'end', ->
        console.log "[GROUPME RESPONSE] #{response.statusCode} #{data}"
    req.end(json)