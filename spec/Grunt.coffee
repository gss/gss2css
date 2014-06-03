fs = require 'fs'
path = require 'path'
chai = require 'chai'

describe 'Grunt task for GSS to CSS precompilation', ->
  fs.readdirSync(path.resolve(__dirname, 'fixtures')).forEach (item) ->
    return if item is 'base'
    describe "Compiling #{item}", ->
      it 'should produce expected result', ->
        replacer = /[\n\s"']*/g
        itemPath = path.resolve __dirname, "fixtures/#{item}"
        try
          expected = fs.readFileSync "#{itemPath}/compiled.html", 'utf-8'
          result = fs.readFileSync "#{itemPath}/grunt.html", 'utf-8'
        catch e
          expected = ''
        expected = expected.replace replacer, ''
        result = result.replace replacer, '' if result
        chai.expect(result).to.equal expected

