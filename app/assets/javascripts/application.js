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
//= require goal
//= require helper
//= require schools
//= require jquery.iframe-transport
//= require jquery.remotipart
//= require rails.validations
//= require rails.validations.simple_form
//= require rails.validations.customValidators

$(document).ready(function() {
    $('.pagination-container.ajax .pagination a').attr('data-remote', 'true');
    $('.pagination-container.ajax .pagination a').click(function(){
    	$(this).parents('.pagination').siblings('.loading').removeClass('hide');
    });

	  Placeholders.init({
	  	live: true, //Apply to future and modified elements too
    	hideOnFocus: true //Hide the placeholder when the element receives focus
	  });


	  if(typeof parent.setiFrameHeight == 'function'){
      parent.setiFrameHeight(document.body.scrollHeight);
    }

    // Require jquery.ba-resize plugin.
    $("body").resize(function(e){
      // This condition check is very important to prevent infinit loop.
      if($(this).find('#iframe-view-as').length > 0) // If in the main page
        return false;

      var height = $(e.currentTarget).height();

      if(height && height > 0){
        if(typeof parent.setiFrameHeight == 'function'){
          parent.setiFrameHeight(height);
        }
      }
    });
});

function setiFrameHeight(height){
	if($('#iframe-view-as').length > 0){
		$('#iframe-view-as').attr('height', height);
	}
};

