window.teacher =
  setup: -> 
    @setup_student_panel()
    $('.teacher-student a.student-link, .teacher-student a.teacher-link').livequery((e) ->
      $(this).tooltip()
    )
    @setup_teacher_dialog()
    @setup_search()

  setup_student_panel: ->
    $('.students-container a.teacher-student-handler, 
       .teachers-container a.student-teacher-handler').livequery('click', (e) -> 
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

      data = $("#teacher-form").serialize()
      url = $("#teacher-form").attr('action')

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
            teacher_dialog = $(res.html)
            $("#teacher-dialog").html(teacher_dialog.html())
      })
      
      return false
    )

  setup_search: ->
    ajax_paging_link = (target) ->      
      $('.admin.search .result-container ' + target + ' .pagination a').livequery('click', (e) ->
        e.preventDefault()
        url = $.trim($(this).attr('href'))
        if url != '#' && url != ''
          $(target).find('.loading').removeClass('hide')
          
          $.ajax({
            url: url,
            type: 'GET',
            dataType: 'script',
            complete: (xhr) ->
              if xhr.status == 200
                $(target).html(xhr.responseText)
          })
          
          return false
      )

    ajax_paging_link('#teachers-list')
    ajax_paging_link('#students-list')
