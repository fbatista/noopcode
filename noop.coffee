Posts = new Meteor.Collection 'posts'
Comments = new Meteor.Collection 'comments'

if Meteor.is_client

  ###
    Client Initialization functions
  ###

  $articles = {jquery: $ '.article_header'}

  Meteor.subscribe 'posts'
  Meteor.subscribe 'comments'

  Template.comment.user = ->
    Meteor.users.findOne(@.user_id)?.username

  Template.post.bodyPreview = ->
    @.body[0..50]

  Template.posts.posts = ->
    Posts.find({}, {sort: {created_at: -1}})

  Template.post.comments = ->
    Comments.find({post_id: @._id}, {sort: {created_at: -1}})

  Template.post.events = 
    #show new comment form
    "click .add-comment": (e)->
      Session.set "new_comment_post_id", @._id
      $textarea = $(e.target).parent('.add-comment').next().find('textarea')
      setTimeout ->
        $textarea.focus()
      , 50
    "click .thumbs_up": (e)->
      Posts.update @._id, {$inc: {votes: 1}}
    "click .thumbs_down": (e)->
      Posts.update @._id, {$inc: {votes: -1}}

  Template.posts.rendered = ->
    $articles.jquery = $ '.article_header'

  Template.posts.events = 
    #create new comment
    "keyup textarea": (e)->
      #if enter-pressed, create comment.
      switch e.keyCode
        when $.ui.keyCode.ENTER
          if !e.shiftKey
            e.preventDefault
            $textarea = $(e.target)
            Comments.insert {created_at: new Date(), post_id: Session.get('new_comment_post_id'), body: $textarea.val(), user_id: Meteor.user()?._id}
            $textarea.val("")
            $('body').click()
      false

  Template.create_post.events =
    "click #create_post": (e)->
      new_post = {created_at: new Date(), votes: 0}
      new_post[field.name]=field.value for field in $('#create_post_form').serializeArray()
      Posts.insert new_post
      #clear form
      $('#create_post_form').get(0)?.reset()

  PostsRouter = Backbone.Router.extend 
    routes: 
      "posts/:post_id": "view_post"
      "": "home"
    home: ->
      ($ "section").show()
      Session.set "post_id", null
    view_post: (post_id)->
      Session.set "post_id", post_id
    goto_post: (post_id)->
      this.navigate "posts/#{post_id}", true
    goto_home: ->
      this.navigate "", true

  Router = new PostsRouter

  Meteor.startup ->
    Backbone.history.start {pushState: true}

if Meteor.is_server
  Meteor.publish 'comments', ->
    Comments.find {}, {sort: {created_at: -1}}

  Meteor.publish 'posts', ->
    Posts.find {}, {sort: {created_at: -1}}

  Meteor.publish null, ->
    Meteor.users.find {}, {fields: {services: 0, private: 0}}
  , {is_auto: true}

  Meteor.startup ->
    # code to run on server at startup

    is_admin = (user_id)->
      !!Meteor.users.findOne
        _id: user_id
        admin: true

    is_owner = (user_id, things)->
      _.all things, (thing)->
        thing.user_id == user_id

    Posts.allow 
      insert: is_admin
      update: is_admin
      remove: is_admin

    Comments.allow
      insert: -> true
      update: is_owner
      remove: is_owner
