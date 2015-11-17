express = require 'express'
bodyParser = require 'body-parser'
Slack = require 'slack-client'

slackToken = 'YOUR_TOKEN'
autoReconnect = true
autoMark = true

slack = new Slack(slackToken, autoReconnect, autoMark)
slack.login()

app = express();
app.get '/', (req, res, next)->
#  console.log(slack.channels)
#  console.log(req.query)
#  console.log(channel)
  if req.query.text.toLowerCase() == 'amr'
    channel = slack.getChannelGroupOrDMByID(req.query.channel_id)
    channel.send 'http://blastdev.com?' + new Date().getTime()
  else if req.query.text.toLowerCase().substr(0, 4) == 'say '
    #todo: refactor if time allows
    channel = slack.getChannelGroupOrDMByID(req.query.channel_id)
    channel.send req.query.text.substring(4)
    
  res.status(200).send(null)

app.listen(8181);