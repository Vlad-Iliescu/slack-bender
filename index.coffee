express = require 'express'
bodyParser = require 'body-parser'
Slack = require 'slack-client'
config = require('./config.json')

slackToken = config.slackToken
autoReconnect = config.autoReconnect
autoMark = config.autoMark

slack = new Slack(slackToken, autoReconnect, autoMark)
slack.login()

initChannel = (id) ->
  slack.getChannelGroupOrDMByID(id)

#sendGiphyData = (channel_id)->
#  Unfortunately bots can't use commands
#  http.post( 'https://' + config.organisation + '.slack.com/api/chat.command?t=' + new Date().getTime(),
#    { agent: 'webapp', command: '/giphy', text: 'meal', channel: channel_id, token: config.slackToken, _attempts:1 } 
#  )
  
app = express();
app.get '/', (req, res, next)->
  text = req.query.text || ''
  command = text.toLowerCase().split(' ')[0]
  response = null

  if command == 'amr'
    channel = initChannel(req.query.channel_id)
    channel.send 'http://blastdev.com?' + new Date().getTime()
      
  else if command == 'say'
    channel = initChannel(req.query.channel_id)
    channel.send text.substring(4)
    
  else if command == 'topic'
    channel = initChannel(req.query.channel_id)
    days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    day = days[new Date().getDay()]
    channel.setTopic('Fucking ' + day + '!!')
    
  else if command == 'meal'
    channel = initChannel(req.query.channel_id)
    now = new Date();
    noon = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 12, 30, 0)
    diff = noon - now

    if diff > 5*60*1000 # 00:00 -> 12:15
      hours =  Math.floor(diff / (1000*60*60))
      diff -= hours*60*60*1000
      minutes =  Math.floor(diff / (1000*60))
      diff -= minutes*60*1000
      seconds =  Math.floor(diff / 1000)
      channel.send(
        (hours > 0 ? '' + hours.toFixed(0) + ' hours ' : '') + 
          ((minutes > 0 || hours > 0) ? '' + minutes + 'minutes ' : '') + 
          (seconds + 'seconds `till meal. Hehe, sucker!'))
      
    else if diff <= 5*60*1000 || diff >= -30*60*1000 # 12:25 -> 13:00
      channel.send('No giphy! But get ready for meal.')

    else #past 13:00 
      channel.send('Meal ended long time aqo. I\'m so embarassed, I wish everyone was dead except me!')
    
  else
    response = "Usage: \n/bender amr \n/bender say [text] \n/bender topic \n/bender meal"
      
  res.status(200).send(response)

app.listen(8181);