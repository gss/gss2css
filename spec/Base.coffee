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
    lib.open "#{baseUrl}/spec/fixtures/base/original.html",
      width: 600
    , (err, p, ph) ->
      phantom = ph
      page = p
      chai.expect(err).to.be.a 'null'
      chai.expect(page).to.be.an 'object'
      done()
  it 'should be able to talk to GSS on the page', (done) ->
    page.evaluate ->
      GSS.engines.root.vars
    , (err, result) ->
      chai.expect(result).to.be.an 'object'
      chai.expect(result['::window[width]']).to.be.a 'number'
      chai.expect(result['$hello[width]']).to.equal 200
      chai.expect(result['$hello[x]']).to.equal 192
      done()
  it 'after resizing the values should have changed', (done) ->
    lib.resize page,
      width: 800
      height: 600
    , (err, page, result) ->
      chai.expect(result).to.be.an 'object'
      chai.expect(result['::window[width]']).to.be.a 'number'
      chai.expect(result['$hello[width]']).to.equal 200
      chai.expect(result['$hello[x]']).to.equal 292
      done()
  it 'should be able to remove GSS from page', (done) ->
    replacer = /[\n\s"']*/g
    expected = fs.readFileSync path.resolve(__dirname, 'fixtures/base/removed.html'), 'utf-8'
    expected = expected.replace replacer, ''
    lib.removeGss page, (err, cleaned) ->
      cleaned = cleaned.replace replacer, ''
      chai.expect(cleaned).to.equal expected
      done()
  it 'should be able to inject CSS into the page', (done) ->
    replacer = /[\n\s"']*/g
    original = fs.readFileSync path.resolve(__dirname, 'fixtures/base/removed.html'), 'utf-8'
    expected = fs.readFileSync path.resolve(__dirname, 'fixtures/base/injected.html'), 'utf-8'
    expected = expected.replace replacer, ''
    css = """
    #hello {
      color: red;
    }
    """
    lib.injectCss original, css, (err, injected) ->
      injected = injected.replace replacer, ''
      chai.expect(injected).to.equal expected
      done()
  it 'should be able to precompile to CSS', (done) ->
    @timeout 0
    replacer = /[\n\s"']*/g
    expected = fs.readFileSync path.resolve(__dirname, 'fixtures/base/compiled.html'), 'utf-8'
    expected = expected.replace replacer, ''
    config =
      sizes:[
        # iPhone portrait
        width: 310
        height: 352
      ,
        # iPad landscape
        width: 1010
        height: 660
      ,
        # Larger
        width: 1405
        height: 680
      ]
    lib.gss2css page, config, (err, html) ->
      #fs.writeFileSync path.resolve(__dirname, 'fixtures/base/compiled.html'), html
      chai.expect(html.replace(replacer, '')).to.equal expected
      done()
