Posts = new Meteor.Collection 'posts'

if Meteor.is_client
  Meteor.subscribe 'posts'

  Template.post_view.post_views = ->
    Posts.find Session.get 'post_id'

  Template.posts.posts = ->
    Posts.find() unless Session.get 'post_id'

  Template.post.bodyPreview = ->
    @.body[0..50]

  Template.post.the_date = ->
    console.log @.created_at
    "#{@.created_at}"

  Template.post.events = 
    "click a": (e)->
      e.preventDefault()
      e.stopPropagation()
      #show full article
      Router.goto_post @._id

  Template.posts.in_list_view = ->
    Session.equals("post_id", null)

  Template.create_post.events =
    "click #create_post": (e)->
      new_post = {created_at: new Date()}
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
  Meteor.publish 'posts', ->
    Posts.find()

  Meteor.startup ->
    # code to run on server at startup

    is_admin = (user_id)->
      !!Meteor.users.findOne
        _id: user_id
        admin: true
    
    Posts.allow 
      insert: is_admin
      update: is_admin
      remove: is_admin
