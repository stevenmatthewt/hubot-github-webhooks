path = require 'path'
chai = require 'chai'
expect = chai.expect
request = require 'supertest'
Robot = require 'hubot/src/robot'
Review = require '../../../src/Review'

process.setMaxListeners(25)

postJson = (router, json) ->
  request(router)
    .post('/hubot/gh')
    .send(json)
    .expect(200, ->)

expectEventWithReview = (robot, eventName, done) ->
  robot.on eventName, (review) ->
    expect(review.repo).to.equal('jpalmour/hubot-active-owner')
    expectedUrl = 'https://github.com/jpalmour/hubot-active-owner/pull/2'
    expect(review.url).to.equal(expectedUrl)
    expect(review.number).to.equal(2)
    expect(review.key).to.equal('jpalmour/hubot-active-owner/2')
    done()

describe 'Hubot with webhook-listener script', ->
  beforeEach ->
    process.env.HUBOT_REVIEW_NEEDED_LABEL = 'rr-review-needed'
    @robot = new Robot null, 'mock-adapter', true, 'TestHubot'
    @robot.adapter.on 'connected', ->
      @robot.loadFile path.resolve('.', 'src', 'scripts'),
        'webhook-listener.coffee'
      @robot.brain.data.reviews ||= {}
    @robot.run()

  afterEach ->
    @robot.server.close()
    @robot.shutdown

  it 'should raise a review-needed event with a Review object when a PR gets " +
    "labeled as REVIEW_NEEDED', (done) ->
    expectEventWithReview @robot, 'review-needed', done
    postJson @robot.router, require('../../fixtures/label-added')
  
  it 'should raise a review-complete event with a Review object when a " +
    "REVIEW_NEEDED label is removed from a PR', (done) ->
    expectEventWithReview @robot, 'potential-review-complete', done
    postJson @robot.router, require('../../fixtures/label-removed')

  it 'should raise a review-complete event with a Review object when a PR " +
    "is closed', (done) ->
    expectEventWithReview @robot, 'potential-review-complete', done
    postJson @robot.router, require '../../fixtures/pr-closed'
