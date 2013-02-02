pty       = require 'pty.js'
http      = require 'http'
express   = require 'express'

port      = parseInt(process.env.PORT || 8000)
term_cmd  = process.env.TERM_CMD || "bash"
app       = express()
buff      = []

app.use(express.static(__dirname))
app.use(express.static(__dirname + '/static'))

web_server = app.listen port, ->
  console.log "web server bound to #{port}"
io = require('socket.io').listen(web_server)

term = pty.fork 'bash', ['-l', '-c', term_cmd], {
  cols: parseInt(process.env.TERM_COLS || 78),
  rows: parseInt(process.env.TERM_ROWS || 35),
  cwd: process.env.HOME,
}

term.on 'data', (data) ->
  buff.push(data)
  io.sockets.emit('data', data)

io.sockets.on 'connection', (socket) ->
  socket.on 'data', (data) ->
    term.write data
  
  # output terminal history
  socket.emit('data', chunk) for chunk in buff
