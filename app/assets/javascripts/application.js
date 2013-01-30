// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery-ui
//= require jquery_ujs
//= require twitter/bootstrap
//= require twitter/bootstrap_ujs
//= require lib/json_parse
//= require lib/jquery.filter_input
//= require lib/jquery-ui-timepicker-addon
//= require lib/highcharts/js/highcharts
//= require lib/Placeholders.min
//= require lib/jquery.ba-resize.min
//= require lib/jquery.livequery.js
//= require jquery_ext
//= require goal
//= require helper
//= require schools
//= require subscribers
//= require jquery.iframe-transport
//= require jquery.remotipart
//= require rails.validations
//= require rails.validations.simple_form
//= require rails.validations.customValidators

// Extension to remove item from an array
Array.prototype.remove = function(s) {
  var i = this.indexOf(s);
  if(i != -1) this.splice(i, 1);
}

global = {
  date_format: "mm-dd-yy",
  date_format_dev: "yy-mm-dd"
};

$(document).ready(function() {
    $('.pagination-container.ajax .pagination a').attr('data-remote', 'true');
    $('.pagination-container.ajax .pagination a').click(function(){
    	$(this).parents('.pagination').siblings('.loading').removeClass('hide');
    });

    $('.pagination li.disabled a').live('click', function(e){
      e.preventDefault();
    });

	  Placeholders.init({
	  	live: true, //Apply to future and modified elements too
    	hideOnFocus: true //Hide the placeholder when the element receives focus
	  });

    /* Handle remote link */

    // Temporary move href attribut to another attribute
    $.each($("a[data-remote=true]"), function(index, value){
      $(value).attr("url_tmp", $(value).attr("href"));
      $(value).attr("href", "#");
    });

    $.each($("a[data-confirm]"), function(index, value){
      if($(this).attr("data-remote") == "true")
        return false; // Skip
      $(value).attr("url_tmp",$(value).attr("href"));
      $(value).attr("href", "#");
    });

    // Handle ajax event to get right
    $("a[data-remote=true]").live("ajax:before", function(event) {
      $(this).attr("href", $(this).attr("url_tmp"));
    });

    $("a[data-remote=true]").live("ajax:complete", function(event) {
      $(this).attr("href", "#");
    });

    $("a[data-confirm]").live("confirm:complete", function(event, answer) {
      if (answer)
        $(this).attr("href", $(this).attr("url_tmp"));
    });

	  // if(typeof parent.setiFrameHeight == 'function'){
   //    parent.setiFrameHeight(document.body.scrollHeight);
   //  }

   //  // Require jquery.ba-resize plugin.
   //  $("body").resize(function(e){
   //    // This condition check is very important to prevent infinit loop.
   //    if($(this).find('#iframe-view-as').length > 0) // If in the main page
   //      return false;

   //    var height = $(e.currentTarget).height();

   //    if(height && height > 0){
   //      if(typeof parent.setiFrameHeight == 'function'){
   //        parent.setiFrameHeight(height);
   //      }
   //    }
   //  });

  
});
function remove_fields(link) {
  $(link).prev("input[type=hidden]").val("1");
  $(link).closest(".fields").hide();
}

function add_fields(link, association, content) {
  var new_id = new Date().getTime();
  var regexp = new RegExp("new_" + association, "g")
  $(link).parent().before(content.replace(regexp, new_id));
}
// function setiFrameHeight(height){
// 	if($('#iframe-view-as').length > 0){
// 		$('#iframe-view-as').attr('height', height);
// 	}
// };

