chai = require 'chai'
lib = require '../index'
fs = require 'fs'
path = require 'path'
baseUrl = 'http://localhost:8002'
describe 'communicating with a web page', ->
  phantom = null
  page = null
  after -> phantom.exit() if phantom
  it 'should be able to open a page', (done) ->
    lib.open "#{baseUrl}/spec/fixtures/base.html", (err, p, ph) ->
      phantom = ph
      page = p
      chai.expect(err).to.be.a 'null'
      chai.expect(page).to.be.an 'object'
      done()
  it 'should be able to talk to GSS on the page', (done) ->
    page.evaluate ->
      GSS.engines[0].vars
    , (err, result) ->
      chai.expect(result).to.be.an 'object'
      chai.expect(result['::window[width]']).to.be.a 'number'
      chai.expect(result['$hello[width]']).to.equal 200
      chai.expect(result['$hello[x]']).to.equal 92
      done()
  it 'after resizing the values should have changed', (done) ->
    lib.resize page,
      width: 800
      height: 600
    , (err, page) ->
      page.evaluate ->
        GSS.engines[0].vars
      , (err, result) ->
        chai.expect(result).to.be.an 'object'
        chai.expect(result['::window[width]']).to.be.a 'number'
        chai.expect(result['$hello[width]']).to.equal 200
        chai.expect(result['$hello[x]']).to.equal 292
        done()
  it 'should be able to remove GSS from page', (done) ->
    replacer = /[\n\s"']*/g
    expected = fs.readFileSync path.resolve(__dirname, 'fixtures/base_removed.html'), 'utf-8'
    expected = expected.replace replacer, ''
    lib.removeGss page, (err, cleaned) ->
      cleaned = cleaned.replace replacer, ''
      chai.expect(cleaned).to.equal expected
      done()
