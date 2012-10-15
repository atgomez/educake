window.teacher =
  setup: -> 
    @setup_student_panel()
    $('.teacher-student a.student-link').tooltip()
    @setup_teacher_dialog()

  setup_student_panel: ->
    $('.students-container a.teacher-student-handler').click((e) -> 
      target = $(this).attr('href')
      if $(this).hasClass('icon-plus')
        $(this).removeClass('icon-plus').addClass('icon-minus')
        $(target).slideDown('fast', ->
          $(target).removeClass('hide')
        )
      else
        $(this).removeClass('icon-minus').addClass('icon-plus')
        $(target).slideUp('fast', ->
          $(target).addClass('hide')
        )       

      return false
    )

  setup_teacher_dialog: ->
    $('#add-teacher').click((e) -> 
      e.preventDefault()
      $('#teacher-dialog').modal('show')
    )

    $("#teacher-form #btn-save-teacher").livequery('click', (e) -> 
      e.preventDefault()
      $("#teacher-form").submit()
    )

    $("#teacher-form").livequery('submit', (e) ->
      e.preventDefault()

      # TODO: implement this method
      
      return false
    )
