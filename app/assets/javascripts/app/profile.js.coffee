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
    $("#change-password").live("click", (e) ->
      e.preventDefault()
      form = $('#account_password_change')
      # Clean old error message
      form.find(".help-inline, .alert").remove()
      form.find(".control-group.error").removeClass("error")

      $(this).fadeOut(100)

      form.slideDown("fast", () ->
        $(this).removeClass("hide")
      )
    )

    # Cancel button
    $(".edit-account form.simple_form .btn-cancel").live("click", (e) ->
      $('#account_password_change').slideUp("fast", () ->
        $('#change-password').fadeIn(100)
      )
    )

    # Show alert message when navigating away from form without saving.
    helper.unsaved_form_message({
      form: ".edit-account form.simple_form"
    })
