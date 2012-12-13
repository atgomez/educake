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
      form = $(this).parents(".section-container").find(".form-container")
      if $(form).hasClass("hide")
        # Clean old error message
        $(form).find(".help-inline, .alert").remove()
        $(form).find(".control-group.error").removeClass("error")

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
      $(this).parents(".section-container").find(".form-display-handler").click()
    )

    # Show alert message when navigating away from form without saving.
    helper.unsaved_form_message({
      form: ".edit-account form.simple_form"
    })
