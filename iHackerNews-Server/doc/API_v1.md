API_v1
====

Endpoints & parameters
----

##User##
---

1. *GET /users/id*
   params => username:string & password:string OR user_email:string & password:string OR facebook_id:string & facebook_auth_token:string
   if success:
   return => {:success => true, :user_info => {:user_id, :user_email, :profile_picture_url}}
   if fail:
   return => {:success => false, :error => "some msg"}


2. *POST /users
   params => username:string & password:string & email:string
   if success:
   return => {:success => true, :user_info => {...as above}}
   if fail:
   return => {:success => false, :error => "somg msg"}
