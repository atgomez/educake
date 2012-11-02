#= require 'lib/jquery.livequery.js'

window.goal =
  setup: ->
    @add_date_picker()
    @setup_form()
    @update_status()
    @validate_character()
    return
  
  validate_character: ->
    $(".controls .numeric.float.required").keypress((e) ->
      theEvent = e or window.event
      if theEvent.keyCode isnt 46 and theEvent.keyCode isnt 8 and theEvent.keyCode isnt 37 and theEvent.keyCode isnt 39  
        key = theEvent.keyCode or theEvent.which
        key = String.fromCharCode(key)
        regex = /[0-9]|\./
        unless regex.test(key)
          theEvent.returnValue = false
          theEvent.preventDefault()  if theEvent.preventDefault
    )
    $(".controls .numeric.integer.required").keypress((e) ->
      theEvent = e or window.event
      if theEvent.keyCode isnt 46 and theEvent.keyCode isnt 8 and theEvent.keyCode isnt 37 and theEvent.keyCode isnt 39  
        key = theEvent.keyCode or theEvent.which
        key = String.fromCharCode(key)
        regex = /[0-9]/
        unless regex.test(key)
          theEvent.returnValue = false
          theEvent.preventDefault()  if theEvent.preventDefault
    )
    $(".controls .numeric.float.optional").keypress((e) ->
      theEvent = e or window.event
      if theEvent.keyCode isnt 46 and theEvent.keyCode isnt 8 and theEvent.keyCode isnt 37 and theEvent.keyCode isnt 39  
        key = theEvent.keyCode or theEvent.which
        key = String.fromCharCode(key)
        regex = /[0-9]|\./
        unless regex.test(key)
          theEvent.returnValue = false
          theEvent.preventDefault()  if theEvent.preventDefault
    )

  add_date_picker: ->
    $(".goal-form .select-date").livequery( ->
      $(this).datepicker({
        dateFormat: "mm-dd-yy",
        yearRange: "-10:+10",
        changeMonth: true,
        changeYear: true
      })
    )
    $("#status_due_date").livequery( ->
      $(this).datepicker({
        dateFormat: "mm-dd-yy",
        yearRange: "-10:+10",
        changeMonth: true,
        changeYear: true
      })
    )

  setup_form: ->
    $('.edit-goal').click((e) -> 
      e.preventDefault()
      $('#_modal' + $(this).attr('target')).modal('show')
    )

    $(".goal-form #btn-save-goal").livequery('click', (e) -> 
      e.preventDefault()
      $(this).parent().parent().submit()
    )

    $(".goal-form").livequery('submit', (e) ->
      e.preventDefault()

      data = $(this).serialize()
      url = $(this).attr('action')
      parent = $(this).parent()
      $.ajax({
        url: url,
        type: 'POST',
        data: data,
        success: (res) -> 
          window.location.reload()
        ,

        error: (xhr, textStatus, error) -> 
          try
            res = $.parseJSON(xhr.responseText)
          catch exc
            res = null

          if res and res.html
            goal_dialog = $(res.html)
            $(parent).html(goal_dialog.html())
      })

      return false
    )

    $(".status-form").livequery('submit', (e) ->
      e.preventDefault()

      data = $(this).serialize()
      url = $(this).attr('action')
      parent = $(this).parent()
      $.ajax({
        url: url,
        type: 'POST',
        data: data,
        success: (res) -> 
          window.location.reload()
        ,

        error: (xhr, textStatus, error) -> 
          try
            res = $.parseJSON(xhr.responseText)
          catch exc
            res = null
          if res and res.html
            goal_dialog = $(res.html)
            $(parent).html(goal_dialog.html())
      })

      return false
    )

  update_status: ->
    $(".complete-checkbox .goal-complete").live 'click', ->
      if $(this).attr("checked")
        $(this).val('true')
      else
        $(this).val('false')

      value = $(this).attr('value')
      url = $(this).attr('url')
      data = {status: value}
      goal_id = $(this).attr('id')

      $.ajax({
        url: url,
        type: 'PUT'
        data: data,
        success: (res) ->
          $("#error_edit_student").addClass('alert alert-success fade in')
          $("#error_edit_student").text('Goal was successfully updated.')
          goal = $('#goal-container-' + goal_id)
          location.reload()
        ,

        error: (xhr, textStatus, error) ->
          $("#error_edit_student").addClass('error_notification')
          $("#error_edit_student").text('Goal was updated failed.')
      })
