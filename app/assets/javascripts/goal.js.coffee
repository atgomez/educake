#= require 'lib/jquery.livequery.js'

window.goal =
  setup: ->
    @add_date_picker()
    @setup_form()
    @update_status()
    return
    
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
    $('#add-goal').click((e) -> 
      e.preventDefault()
      $('#goal-dialog').modal('show')
    )

    $('.edit-goal').click((e) -> 
      e.preventDefault()
      $('#_modal' + $(this).attr('target')).modal('show')
    )

    $(".goal-form #btn-save-goal").livequery('click', (e) -> 
      e.preventDefault()
      $(this).parent().parent().submit()
    )

    $(".goal-form #btn-cancel").livequery('click', (e) ->
      e.preventDefault()
      btn_reset = $(this).siblings(".reset-form-button")
      $(btn_reset).click();
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
