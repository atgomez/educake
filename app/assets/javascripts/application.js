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
//= require jquery.iframe-transport
//= require jquery.remotipart
//= require rails.validations
//= require rails.validations.simple_form
//= require rails.validations.customValidators

// Workaround to fix problem when scrolling element within UI widget
function fix_ui_widget_position(){
  var scroll_event = function(container, widget, target){
    $(container).scroll(function(){
        target = $(target);
        widget = $(widget);
        var pos = $(target).position();        
        var top = pos.top + target.outerHeight() + 23;
        widget.css({'top': top});
    });
  };

  var parent = null;
  $(".modal-body").find(".ui-combobox-input").livequery(function(){
    var widget = $(this).data("autocomplete");
    if(!widget)
      return;
    if(!parent)
      parent = $(this).parents(".modal-body");
    scroll_event(parent, widget.menu.activeMenu, $(this).parent());
  });
};

$(document).ready(function() {
    $('.pagination-container.ajax .pagination a').attr('data-remote', 'true');
    $('.pagination-container.ajax .pagination a').click(function(){
    	$(this).parents('.pagination').siblings('.loading').removeClass('hide');
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

    fix_ui_widget_position();

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

// function setiFrameHeight(height){
// 	if($('#iframe-view-as').length > 0){
// 		$('#iframe-view-as').attr('height', height);
// 	}
// };

