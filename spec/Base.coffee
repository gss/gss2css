chai = require 'chai'
lib = require '../index'
fs = require 'fs'
path = require 'path'
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
        chai.expect(result['$hello[width]']).to.equal 200
        done()
    , 1000
  it 'should be able to remove GSS from page', (done) ->
    replacer = /[\n\s"']*/g
    expected = fs.readFileSync path.resolve(__dirname, 'fixtures/base_removed.html'), 'utf-8'
    expected = expected.replace replacer, ''
    lib.removeGss page, (err, cleaned) ->
      cleaned = cleaned.replace replacer, ''
      chai.expect(cleaned).to.equal expected
      done()
