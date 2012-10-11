#= require 'lib/jquery.livequery.js'

window.goal =
  setup: ->
    @add_date_picker()
    @setup_form()
    return
    
  add_date_picker: ->
    $("#goal-form .select-date").livequery( ->
      $(this).datepicker({"format": "mm-dd-yyyy"})
    )

  setup_form: ->
    $('#add-goal').click((e) -> 
      e.preventDefault()
      $('#goal-dialog').modal('show')
    )

    $("#goal-form").livequery('submit', (e) ->
      e.preventDefault()

      data = $("#goal-form").serialize()
      url = $("#goal-form").attr('action')

      $.ajax({
        url: url,
        type: 'POST',
        data: data,
        success: (res) -> 
          window.location.reload()
        ,

        error: (xhr, textStatus, error) -> 
          console.log("error")
          console.log(xhr)

          try
            res = $.parseJSON(xhr.responseText)
          catch exc
            res = null

          console.log(res)
          if res and res.html
            goal_dialog = $(res.html)
            $("#goal-dialog").html(goal_dialog.html())
      })

      return false
    )
