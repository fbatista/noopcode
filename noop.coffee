Posts = new Meteor.Collection 'posts'
Comments = new Meteor.Collection 'comments'

if Meteor.is_client

  ###
    Client Initialization functions
  ###

  Accounts.ui.config
    requestPermissions:
      facebook: ['user_likes']
    passwordSignupFields: 'USERNAME_AND_OPTIONAL_EMAIL'

  $articles = {jquery: $ '.article_header'}

  Meteor.subscribe 'posts'
  Meteor.subscribe 'comments'

  generate_post_id = (post)->
    "#{post.header.replace(/[ \.,\/:]+/g, "-")}"

  generate_post_name_regex = (post_id)->
    RegExp post_id.replace(/\-/g, "."), "i"

  Template._loginButtonsLoggedInDropdown.rendered = ->
    document.getElementById("login-name-link").innerHTML = "#{Template._loginButtonsLoggedInDropdown.displayName()} <i class='icon-off icon-white'></i>"

  Template._loginButtonsLoggedOutDropdown.rendered = ->
    document.getElementById("login-sign-in-link").innerHTML = "Sign in <i class='icon-user icon-white'></i>"

  Template.post.comments = ->
    Comments.find({post_id: @._id}, {sort: {created_at: -1}})

  Template.post.isCurrent = ->
    if Session.equals "current_article", @._id then "navbar-fixed-top" else ""

  Template.post.safeBody = ->
    new Handlebars.SafeString @.body

  Template.post.bodyPreview = ->
    @.body[0..500]


  Template.post.link = ->
    "/posts/#{generate_post_id @}"

  Template.navigation.post_selected = Template.post.post_selected = Template.posts.post_selected = ->
    Session.get "post_id"

  Template.post.events
    "click .brand": (e)->
      Router.goto_post generate_post_id(@)
      e.preventDefault()
      return false
    "click .add-comment": (e)->
      Session.set "new_comment_post_id", @._id
      $textarea = $(e.target).parent('.add-comment').next().find('textarea')
      setTimeout ->
        $textarea.focus()
      , 50
    "click .thumbs_up": (e)->
      Posts.update @._id, {$inc: {votes: 1}}
      e.preventDefault()
      e.stopPropagation()
    "click .thumbs_down": (e)->
      Posts.update @._id, {$inc: {votes: -1}}
      e.preventDefault()
      e.stopPropagation()

  Template.comment.user = ->
    Meteor.users.findOne(@.user_id)?.username

  Template.posts.posts = ->
    if Session.get "post_id"
      Posts.find({header: generate_post_name_regex(Session.get("post_id"))}, {sort: {created_at: -1}})
    else
      Posts.find({}, {sort: {created_at: -1}})

  Template.posts.rendered = ->
    $articles.jquery = $ '.article_header'
    $('body')
      .on 'fixed_top', 'article', (e, i)->
        Session.set 'current_article', @.id
    $(document)
      .on 'no_fixed_top', (e)->
        Session.set 'current_article', undefined

  Template.posts.events
    #create new comment
    "keyup .dropdown-menu textarea": (e)->
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

  Template.create_post.events
    "click #create_post": (e)->
      new_post = {created_at: new Date(), votes: 0}
      new_post[field.name]=field.value for field in $('#create_post_form').serializeArray()
      Posts.insert new_post
      #clear form
      $('#create_post_form').get(0)?.reset()

  Template.navigation.events
    "click .brand": (e)->
      Router.goto_home()
      e.preventDefault()
      return false

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
      this.navigate "/", true

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
