$ ->
  subscriberObject.setup()

window.subscriberObject =
  setup: ->
    @sendContactEmail()


  sendContactEmail: ->
  	$(".list_subs").find("span").each ->
  		$(this).click ->
  			id = $(this).attr("id").split("_")[1]
  			email = $(this).attr("email")
  			$(".ajax-loading").removeClass("hidden")
  			$.ajax
	        type: "GET"
	        url: "/super_admin/subscribers/"+id+"/contact"
	        data: {}
	        success: (data)->
	          $("#subscribers").html(data)
	          $(".ajax-loading").addClass("hidden")
	          window.location = email
	          return
	        error: (errors, status)->
	        	$(".ajax-loading").removeClass("hidden")
	        	return
