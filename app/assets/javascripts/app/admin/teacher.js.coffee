$ ->
  teacher.setup()

window.teacher =
  setup: -> 
    @setup_student_panel()
    $('.teacher-student a.student-link, .teacher-student a.teacher-link').livequery((e) ->
      $(this).tooltip()
    )
    @setup_teacher_dialog()
    @setup_search()
    @setup_block_link()
    @change_list_teacher()
    @check_school_radio()

  change_list_teacher: ->    
    $("#teacher_selection").live('change', ->
      data = @value
      url = $(this).attr('data-url') + "&teacher_id=" + data

      $.ajax({
        url: url,
        type: 'GET',
        success: (res) ->
          $("#student_selection").html(res)
      })
      
      return false
    )

  check_school_radio: ->
    $("input[name=data]").change ->
      if @value is "classroom"
        $("#teacher_selection").removeAttr("disabled")
        $("#student_selection").attr("disabled", "disabled")
      else if @value is "school"
        $("#teacher_selection").attr("disabled", "disabled")
        $("#student_selection").attr("disabled", "disabled")
      else
        $("#teacher_selection").removeAttr("disabled")
        $("#student_selection").removeAttr("disabled")

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

  setup_block_link: ->
    $(".student-container .link, .teacher-container .link").livequery('click', (e) ->
      url = $(this).attr('href')
      if $.trim(url) != ''
        window.location.href = url
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
      v_method = $("#method").val()
      $.ajax({
        url: url,
        type: v_method,
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
