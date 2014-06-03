chai = require 'chai'
lib = require '../index'
baseUrl = 'http://localhost:8002'
describe 'communicating with a web page', ->
  page = null
  it 'should be able to open a page', (done) ->
    lib.open "#{baseUrl}/spec/fixtures/base.html", (err, p) ->
      page = p
      chai.expect(err).to.be.a 'null'
      chai.expect(page).to.be.an 'object'
      #page.get 'viewportSize', (err, size) -> console.log err, size
      done()
  it 'should be able to talk to GSS on the page', (done) ->
    setTimeout ->
      page.evaluate ->
        GSS.engines[0].vars
      , (err, result) ->
        chai.expect(result).to.be.an 'object'
        chai.expect(result['::window[width]']).to.be.a 'number'
        done()
    , 1000
