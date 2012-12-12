$ ->
  profile.setup()

window.profile =
  setup: ->
    $(".edit-account form.simple_form").live("submit", (e) ->
      e.preventDefault()
      form = $(this)
      method = 'POST'
      url = $(form).attr("action")
      data = $(form).serialize()
      
      $.ajax({
        type: method,
        url: url,
        data: data,
        success: (res) ->
          if(res && res.status == 'ok')
            # Reload
            window.location.reload()
        ,
        error: (xhr) ->
          res = jQuery.parseJSON(xhr.responseText)
          if(res && res.status && res.message)
            helper.flash_message("error", res.message)

          else if(res && res.status && res.html)
            $(form).replaceWith(res.html)

      })
    )

    # Show/hide button
    $(".edit-account .form-display-handler").live("click", (e) ->
      e.preventDefault()
      form = $(this).next(".form-container")
      if $(form).hasClass("hide")
        $(form).slideDown("fast", () ->
          $(this).removeClass("hide")
        )
      else
        $(form).slideUp("fast", () ->
          $(this).addClass("hide")
        )
    )

    # Cancel button
    $(".edit-account form.simple_form .btn-cancel").live("click", (e) ->
      $(this).parents(".control-group").find(".form-display-handler").click()
    )
