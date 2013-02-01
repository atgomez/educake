//= require jquery-ui
//= require jquery_ujs
//= require twitter/bootstrap
//= require twitter/bootstrap_ujs
//= require lib/jquery.livequery.js
//= require app/mobile/goal
//= require app/mobile/mobile_helper

// Configure jQuery mobile.
$(document).on("mobileinit", function(){
  $.mobile.ajaxEnabled = false;  
});
