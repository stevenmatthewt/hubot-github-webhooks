class Push
  constructor: (pushEvent) ->
    @force = pushEvent.forced
    @shaBefore = pushEvent.before
    @repo = pushEvent.repository.full_name
    pushEvent.ref = pushEvent.ref.split('/');
    @branch = pushEvent.ref[2]
    @user = pushEvent.pusher.login
    @time = new Date()

module.exports = Push 
