#= require 'lib/jquery.livequery.js'

window.goal =
  setup: ->
    @add_date_picker()
    @setup_form()
    @update_status()
    return
    
  add_date_picker: ->
    $("#goal-form .select-date").livequery( ->
      $(this).datepicker({"format": "mm-dd-yyyy"})
    )
    $("#status_due_date").livequery( ->
      $(this).datepicker({"format": "mm-dd-yyyy"})
    )

  setup_form: ->
    $('#add-goal').click((e) -> 
      e.preventDefault()
      $('#goal-dialog').modal('show')
    )

    $("#goal-form #btn-save-goal").livequery('click', (e) -> 
      e.preventDefault()
      $("#goal-form").submit()
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
          try
            res = $.parseJSON(xhr.responseText)
          catch exc
            res = null

          if res and res.html
            goal_dialog = $(res.html)
            $("#goal-dialog").html(goal_dialog.html())
      })

      return false
    )

  update_status: ->
    $("#complete_checkbox").live 'click', ->
      value = $("#complete_checkbox").attr('value')
      url = $("#complete_checkbox").attr('url')
      data = {status: value}

      $.ajax({
        url: url,
        type: 'PUT'
        data: data,
        success: (res) ->
          $("#error_edit_student").addClass('alert alert-success fade in')
          $("#error_edit_student").text('Goal was successfully updated.')
        ,

        error: (xhr, textStatus, error) ->
          $("#error_edit_student").addClass('error_notification')
          $("#error_edit_student").text('Goal was updated failed.')
      })










































