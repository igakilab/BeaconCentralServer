Express = require 'express'
BodyParser = require 'body-parser'
Redis = require 'redis'
RedisCollection = require './redis-collection'

searchUserId = (list, id) ->
  for i in [0...list.length]
    if list[i].user_id is id
      return i
  return -1

app = Express()
app.use BodyParser.urlencoded {extended:true}
app.use BodyParser.json()

client = Redis.createClient()
collection = new RedisCollection client, "restful-api", "users"

router = Express.Router()
router.get "/", (req, res) ->
  res.json {message: "Successfully Posted a test message"}

router2 = router.route "/users"
# ADD USER
router2.post (req, res) ->
  userList.push req.body
  res.json {message:"User created!", data:req.body}
router2.get (req, res) ->
  res.json {message:"User list", data:userList}

router3 = router.route "/user/:user_id"
router3.get (req, res) ->
  idx = searchUserId userList, req.params.user_id
  res.json {message:"User info", user_id:req.params.user_id, data:userList[idx]}
router3.put (req, res) ->
  idx = searchUserId userList, req.params.user_id
  if idx > 0
    userList[i] = req.body
    res.json {message:"User updated!", user_id:req.params.user_id, data:req.body}
  else
    res.json {message:"error!", user_id:req.params.user_id, idx_val:idx}
router3.delete (req, res) ->
  idx = searchUserId userList, req.params.user_id
  if idx > 0
    userList.splice idx, 1
    res.json {message:"User deleted!", user_id:req.params.user_id}
  else
    res.json {message:"error!", user_id:req.params.user_id}


app.use "/api", router
app.listen 1337
console.log "listen on port :1337:"
