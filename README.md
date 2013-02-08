# A meteor.js based blog

This repo contains a fully working blog engine built on top of meteor.js.

In order to make it work for you, you will need to clone it, and after deploying it, create your first user.

After that, you need to give that user "admin" status, by setting his "admin" flag to true on mongodb. 

At the moment it needs to be done manually, but in the future the idea is to have a configuration file parsed on startup, in order to create the admin user, if it doesn't exist.