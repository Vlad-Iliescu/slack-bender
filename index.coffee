express = require 'express'
Slack = require 'slack-client'
config = require './config.json'

slackToken = config.slackToken
autoReconnect = config.autoReconnect
autoMark = config.autoMark

slack = new Slack(slackToken, autoReconnect, autoMark)
slack.login()

#########################################################################################################
##                                    Functions                                                        ##
#########################################################################################################

initChannel = (id) ->
  slack.getChannelGroupOrDMByID(id)
  
timeToText = (diff) ->
  hours =  Math.floor(diff / (1000*60*60))
  diff -= hours*60*60*1000
  minutes =  Math.floor(diff / (1000*60))
  diff -= minutes*60*1000
  seconds =  Math.floor(diff / 1000)

  hours_text = ''
  if hours > 0
    hours_text += hours + ' hour'
    if hours > 1
      hours_text += 's'

  minutes_text = ''
  if minutes > 0 || hours > 0
    minutes_text += minutes + ' minute'
    if minutes > 1
      minutes_text += 's'
  
  seconds_text = '' + seconds + ' second'
  if seconds > 1
    seconds_text += 's'
    
  [hours_text, minutes_text, seconds_text].join(' ')

##########################################################################################################
##                                      APP                                                             ##
##########################################################################################################
  
  
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
    diff = noon - now - 60*60*1000

    if diff > 5*60*1000 # 00:00 -> 12:15
      channel.send(timeToText(diff) + ' `till meal. Hehe, sucker!')
      
    else if diff <= 5*60*1000 && diff >= -30*60*1000 # 12:25 -> 13:00
      channel.send('http://blastdev.com/bender.php?term=meal&t=' + new Date().getTime())

    else #past 13:00 
      channel.send('Meal ended long time ago. I\'m so embarassed, I wish everyone was dead except me!')
    
  else
    response = "Usage: \n/bender amr \n/bender say [text] \n/bender topic \n/bender meal"
      
  res.status(200).send(response)

app.get '/webshot', (req, res, next)->
  webshot = require('webshot')
  fs      = require('fs')

  renderStream = webshot('google.com')
  file = fs.createWriteStream('google.png', {encoding: 'binary'})

  renderStream.on 'data', (data)->
    file.write(data.toString('binary'), 'binary')

app.listen(8181);
