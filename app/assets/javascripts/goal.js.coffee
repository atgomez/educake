$ ->
  goal.setup()

window.goal =
  setup: ->
    @setup_form()
    @update_grade()
    @clickOnGoal()
    return

  clickOnGoal: -> 
    $(".grade a.goal").live 'click', () ->
      id_content = $(this).attr("href")
      id = id_content.split("_")[1]
      current_iframe = $('#chart').attr("src")
      id_content = $(this).attr("href")
      if $(this).hasClass("icon-plus")
        $(this).removeClass("icon-plus").addClass("icon-minus")
        $(id_content).slideDown('fast', ->
          $(id_content).attr("style","display:block;")
        )
        helper.loadGrades(id)
        $('#chart').attr("src", "/charts/goal_chart?goal_id="+id + "&color=" + $(this).attr('color') + "&user_id=" + $("#user_id").val());
        $('#chart').attr("height", "500");
        $('#chart').attr("width", "100%");
        $(".grade a.goal").each ->
          if $(this).hasClass("icon-minus") && ($(this).attr("href") != id_content)
            $(this).removeClass("icon-minus").addClass("icon-plus")
            id = $(this).attr("href")
            #$(id).attr("style","display:none;")
            $(id).slideUp('fast', ->
              $(id).attr("style","display:none;")
            )
        window.chartMode = 'view_goal'
      else if $(this).hasClass("icon-minus")
        if $("#check_is_add_grade").val() == "true"
          $('#chart').attr("height", "0");
          $('#chart').attr("width", "0%");
        $(this).removeClass("icon-minus").addClass("icon-plus")
        $(id_content).slideUp('fast', ->
          $(id_content).attr("style","display:none;")
        )
        $('#chart').attr("src", "/charts/student_chart?student_id="+ $("#student_id").val() + "&user_id=" + $("#user_id").val());
        window.chartMode = 'view_all'
      return

  setup_form: ->
    @setup_wizard()

    $(".goal-form .extended-combobox").livequery(() ->
      $(this).readonly_combobox()
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

        error: (xhr, textStatusx, error) -> 
          try
            res = $.parseJSON(xhr.responseText)
          catch exc
            res = null

          if res and res.html
            goal_dialog = $(res.html)
            $(parent).html(goal_dialog.html())
            goal.get_curriculum()
      })

      return false
    )

    $(".grade-form").livequery('submit', (e) ->
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

  setup_wizard: ->
    $(".wizard-content .wizard-action").live("click", (e) ->
       e.preventDefault()
       tab_nav = $(".wizard-nav").find("a[href='" + $(this).attr("data-target") + "']")
       tab_nav.tab('show')
       total_steps = $(".wizard-nav a").length
       current_step = $(".wizard-nav a").index(tab_nav) + 1
       step_html = "(" + current_step + "/" + total_steps + ")"
       $(".wizard-step-indicator").html(step_html)
    )

    $(".reset-on-changed").live("change", (e) ->
      # Reset the client-side validation states.
      goal.get_curriculum()
    )

  get_curriculum: ->
    # Collect all curriculum attributes
    attrs = {}
    $("#curriculum.tab-pane").find("select[name!='goal[curriculum_attributes]']").each(->
      attrs[$(this).attr('name')] = $(this).val()
    )

    # Show the loading
    loading = $("#curriculum.tab-pane").find(".loading").removeClass("hide")

    $.ajax({
      url: "/goals/curriculum_info",
      type: "POST",
      data: attrs,
      success: (res) ->
        curriculum_desc = $("#curriculum.tab-pane .curriculum-description")
        if(res && res.id)          
          if res.description1
            curriculum_desc.find(".description1").html(res.description1)
          else
            curriculum_desc.find(".description1").html("")
          if res.description2
            curriculum_desc.find(".description2").html(res.description2)
          else
            curriculum_desc.find(".description2").html("")
          curriculum_desc.removeClass("hide")
          curriculum_desc.find(".error").addClass("hide")
          curriculum_desc.find(".control-label").removeClass("hide")
        else if(res && res.error)
          curriculum_desc.find(".error").removeClass("hide").html(res.error)
          curriculum_desc.find(".control-label").addClass("hide")
          curriculum_desc.find(".description1, .description2").html("")
          curriculum_desc.removeClass("hide")
        else
          # Clear the old result
          curriculum_desc.find(".description1, .description2").html("")
          curriculum_desc.addClass("hide")
          curriculum_desc.find(".error").addClass("hide")
          curriculum_desc.find(".control-label").removeClass("hide")
          
        # Hide the loading
        $(loading).addClass("hide")
    })

  update_grade: ->
    $(".complete-checkbox .goal-complete").live 'click', ->
      if $(this).attr("checked")
        $(this).val('true')
      else
        $(this).val('false')

      value = $(this).attr('value')
      url = $(this).attr('url')
      data = {grade: value}
      goal_id = $(this).attr('id')

      $.ajax({
        url: url,
        type: 'PUT'
        data: data,
        success: (res) ->
          if res && res.message
            $("#error_edit_student").removeClass('alert-error').addClass('alert alert-success fade in')
            $("#error_edit_student .message").text(res.message)
            window.location.reload()
        ,

        error: (xhr, textStatus, error) ->
          res = JSON.parse(xhr.responseText)
          if res && res.message
            $("#error_edit_student").removeClass('alert-success').addClass('alert alert-error fade in')
            $("#error_edit_student .message").text(res.message)
      })


