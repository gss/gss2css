chai = require 'chai'
lib = require '../index'

describe 'Options normalization', ->
  it 'should keep a sizes array as-is', ->
    options =
      sizes: [
        width: 1024
        height: 768
      ,
        width: 800
        height: 600
      ]
    expected = options
    chai.expect(lib.normalizeOptions(options)).to.eql expected

  it 'should produce a single size with fixed ranges', ->
    options =
      ranges:
        width: 1024
        height: 768
    expected =
      sizes: [
        width: 1024
        height: 768
      ]
    chai.expect(lib.normalizeOptions(options)).to.eql expected

  it 'should produce a two sizes with short width range', ->
    options =
      ranges:
        width:
          from: 1024
          to: 1034
          step: 10
        height: 768
    expected =
      sizes: [
        width: 1024
        height: 768
      ,
        width: 1034
        height: 768
      ]
    chai.expect(lib.normalizeOptions(options)).to.eql expected

  it 'should produce a four sizes with short ranges', ->
    options =
      ranges:
        width:
          from: 700
          to: 800
          step: 100
        height:
          from: 500
          to: 600
          step: 100
    expected =
      sizes: [
        width: 700
        height: 500
      ,
        width: 800
        height: 500
      ,
        width: 700
        height: 600
      ,
        width: 800
        height: 600
      ]
    chai.expect(lib.normalizeOptions(options)).to.eql expected
