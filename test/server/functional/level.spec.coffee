require '../common'

describe 'Level', ->

  level =
    name: "King's Peak 3"
    description: 'Climb a mountain.'
    permissions: simplePermissions

  urlLevel = '/db/level'
  
  levels = {}

  it 'clears things first', (done) ->
    clearModels [Level], (err) ->
      expect(err).toBeNull()
      done()

  it 'can make a Level.', (done) ->
    loginJoe (joe) ->
      level.permissions = [{target:joe._id, access: 'owner'}]
      request.post {uri:getURL(urlLevel), json:level}, (err, res, body) ->
        expect(res.statusCode).toBe(200)
        levels[0] = body
        done()

  it 'get schema', (done) ->
    request.get {uri:getURL(urlLevel+'/schema')}, (err, res, body) ->
      expect(res.statusCode).toBe(200)
      body = JSON.parse(body)
      expect(body.type).toBeDefined()
      done()
      
  it 'uses the latest version to determine write permissions', (done) ->
    loginJoe ->
      open_level = _.cloneDeep(levels[0])
      open_level.permissions.push { target:'public', access:'write' }
      request.post {uri:getURL(urlLevel), json:open_level}, (err, res, body) ->
        expect(res.statusCode).toBe(200)
        levels[1] = body
        closed_level = _.cloneDeep(levels[0])
        request.post {uri:getURL(urlLevel), json:closed_level}, (err, res, body) ->
          expect(res.statusCode).toBe(200)
          levels[2] = body
          loginSam ->
            hack_level = _.cloneDeep(levels[1])
            request.post {uri:getURL(urlLevel), json:hack_level}, (err, res, body) ->
              expect(res.statusCode).toBe(403)
              done()
 