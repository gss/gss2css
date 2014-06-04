fs = require 'fs'
path = require 'path'
lib = require '../index'
chai = require 'chai'
baseUrl = 'http://localhost:8002'

fs.readdir path.resolve(__dirname, 'fixtures'), (err, items) ->
  return if err
  items.forEach (item) ->
    return if item is 'base'
    itemPath = path.resolve __dirname, "fixtures/#{item}"
    itemUrl = "#{baseUrl}/spec/fixtures/#{item}/original.html"
    describe "Precompiling #{item}", ->
      phantom = null
      after -> phantom.exit() if phantom
      it 'should produce expected with three fixed sizes', (done) ->
        config =
          sizes:[
            # Good old displays
            width: 800
            height: 600
          ,
            # iPad landscape
            width: 1010
            height: 660
          ,
            # Larger
            width: 1405
            height: 680
          ]
        @timeout 0
        replacer = /[\n\s"']*/g
        try
          expected = fs.readFileSync "#{itemPath}/compiled.html", 'utf-8'
        catch e
          expected = ''
        expected = expected.replace replacer, ''
        lib.open itemUrl, (err, page, ph) ->
          phantom = ph
          lib.gss2css page, config, (err, html) ->
            #fs.writeFileSync "#{itemPath}/compiled.html", html
            chai.expect(html.replace(replacer, '')).to.equal expected
            done()
      it 'should produce expected with ranged width', (done) ->
        @timeout 0
        config =
          ranges:
            width:
              from: 400
              to: 1300
              step: 10
            height: 600
        replacer = /[\n\s"']*/g
        try
          expected = fs.readFileSync "#{itemPath}/compiled-range.html", 'utf-8'
        catch e
          expected = ''
        expected = expected.replace replacer, ''
        lib.open itemUrl, (err, page, ph) ->
          phantom = ph
          lib.gss2css page, config, (err, html) ->
            #fs.writeFileSync "#{itemPath}/compiled-range.html", html
            chai.expect(html.replace(replacer, '')).to.equal expected
            done()
