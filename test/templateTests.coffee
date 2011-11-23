vows        = require 'vows'
assert      = require 'assert'
fs          = require 'fs'
path        = require 'path'
coffeecloud = require '../lib/coffeecloud'

@assertListsEqual = (actualList, expectedList) ->
  assert.equal actualList.length, expectedList.length
  for key, val of expectedList
    for k, v of val.Properties
      assert.deepEqual actualList[key].Properties[k], v
    expected = {}
    expected[key] = val
    actual = {}
    actual[key] = actualList[key]
    assert.deepEqual actual, expected
  assert.deepEqual expectedList, actualList

suite = vows.describe 'WordPress Template Test Suite'
suite.addBatch
  'when parsing WordPressTemplate.coffee':
    topic: ->
      raw = ''
      input = fs.createReadStream path.normalize '../examples/WordPress-1.0.0.template.original'
      input.on 'data', (d) =>
        raw += "#{d}"
      input.on 'end', =>
        generatedTemplate = require('../examples/WordPress-1.0.0.template.coffee')
        originalTemplate = JSON.parse(raw)
        #console.log "generatedTemplate - #{JSON.stringify(generatedTemplate).length}, originalTemplate - #{JSON.stringify(originalTemplate).length}"
        @callback originalTemplate, generatedTemplate
      return
    'Descriptions are the same': (originalTemplate, generatedTemplate) =>
      return if originalTemplate is null or generatedTemplate is null
      assert.equal generatedTemplate.Description, originalTemplate.Description
    'Parameters are the same': (originalTemplate, generatedTemplate) =>
      return if originalTemplate is null or generatedTemplate is null
      @assertListsEqual generatedTemplate.Parameters, originalTemplate.Parameters
    'Resources are the same': (originalTemplate, generatedTemplate) =>
      return if originalTemplate is null or generatedTemplate is null
      @assertListsEqual generatedTemplate.Resources, originalTemplate.Resources
    'Outputs are the same': (originalTemplate, generatedTemplate) =>
      return if originalTemplate is null or generatedTemplate is null
      @assertListsEqual generatedTemplate.Outputs, originalTemplate.Outputs
  'when using resource types':
    topic: ->
      coffeecloud ->
        @AWS.AutoScaling.ScalingPolicy 'scalePolicy'
        @Param.String 'shortParam'
    'it does not break': (topic) ->
      assert.ok topic?
      assert.ok topic.Parameters?
      assert.ok topic.Resources?
      assert.ok topic.Outputs?
    'scaling policy is good': (topic) ->
      assert.ok topic.Resources.scalePolicy?
    'short param is good': (topic) ->
      assert.ok topic.Parameters.shortParam?
  'when using a blank template':
    topic: ->
      coffeecloud ->
    'it is not null': (topic) ->
      assert.ok topic?
    'there is no description': (topic) ->
      assert.ok Object.keys(topic).indexOf('Description') is -1
    'there is a Parameters block': (topic) ->
      assert.ok topic.Parameters?
    'there is a Resources block': (topic) ->
      assert.ok topic.Resources?
    'there is a Outputs block': (topic) ->
      assert.ok topic.Outputs?

suite.run()
