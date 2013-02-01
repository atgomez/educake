$ ->
  goal.setup()

window.goal =
  setup: ->
    @setup_form()
    @update_grade()
    @clickOnGoal()
    @clickOnGoalType()
    @clickOnAddProgress()
    @clickOnCancel()
    @checkOnSelectGrade()
    @clickOnAddGoalLink()
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

  clickOnGoalType: ->
    $("#new-goal-container").delegate ".radio_buttons", "click", ()->
      if $(this).attr("value") == "true"
        $(".percentage").show()
        $(".objective").hide()
      else if $(this).attr("value") == "false"
        $(".objective").show()
        $(".percentage").hide()
        $("#goal_goal_x").parent().parent().removeClass("control-group")
        $("#goal_baseline_x").parent().parent().removeClass("control-group")
      return

  clickOnCancel: ->
    $("#cancel_goal_form").live "click", ->
      $('.modal-backdrop.fade.in').remove();
    return


  clickOnAddProgress: ->
    $(".progress-report-container").find("a[class='add_link']").live "click", () ->
      count = parseInt($("#count_field").val())
      count =  count + 1
      if count <= 3
        $("#count_field").attr("value", count)
        $(this).show()
      if count >= 3 
        $(this).hide()
      return

  checkOnSelectGrade: ->
    $("#grade_goal_id").live "change", () ->
      goal_type = $(this).find('option:selected').attr('goal_type')
      if goal_type == "true"
        $(".grade-percentage").show()
        $(".grade-objective").hide()
      else
        $(".grade-percentage").hide()
        $(".grade-objective").show()
    return
  clickOnAddGoalLink: ->
    $("#add-goal11").live "click", () ->
      $(this).removeAttr("data-remote")
      $(this).removeAttr("href")
    return

  setup_form: ->
    @setup_wizard()

    $(".goal-form .extended-combobox").livequery(() ->
      $(this).combobox()
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

    $(".goal-form .reset-on-changed").live("change", (e) ->
      # Reset the client-side validation states.
      goal.get_curriculum($(this).attr('name'))
    )

  get_curriculum: (current_param_name) ->
    # Collect all curriculum attributes
    attrs = {}
    container = $("#curriculum.tab-pane")
    if current_param_name
      # Workaround to get the attribute name
      param_name = current_param_name.replace("goal[curriculum_attributes]", "")
      param_name = param_name.replace("[", "")
      param_name = param_name.replace("]", "")
      attrs['current_param_name'] = param_name

    container.find("select[name!='goal[curriculum_attributes]']").each( ->
      name = $(this).attr('name')
      attrs[$(this).attr('name')] = $(this).val()
    )

    # Show the loading
    loading = $("#curriculum.tab-pane").find(".loading").removeClass("hide")

    # The order of these items is very important, BE CAREFUL when change it.
    keys_map = {
      "curriculum_core_id": "curriculum_cores",
      "subject_id": "subjects",
      "curriculum_grade_id": "curriculum_grades",
      "curriculum_area_id": "curriculum_areas",
      "standard": "standards"
    }

    $.ajax({
      url: "/goals/curriculum_info",
      type: "POST",
      data: attrs,
      success: (res) ->
        curriculum_desc = $("#curriculum.tab-pane .curriculum-description")
        curriculum_name = $("#goal.tab-pane .curriculum-name-place-holder")        

        # Dynamic change the select box
        if(res && res.extra_info)
          extra_info = res.extra_info
          # Contains fields that are skipped
          skipped_fields = []
          fields = []

          after_current_field = false

          # Detect the fields need updating.
          $.each(keys_map, (k, v) ->
            select_name = "goal[curriculum_attributes][" + k + "]"
            
            if select_name == current_param_name
              after_current_field = true
              return # Skip the current select box

            select = container.find("select[name='" + select_name + "']")
            options = extra_info[v]
            found = true
            # Find if there is anything not matched
            for opt in options
              if select.find("option[value='" + opt[1] + "']").length == 0
                found = false
                break

            if (!found && k != 'curriculum_core_id') || after_current_field
              fields.push(k)
            else
              skipped_fields.push(k)
          )

          # Change the value of skipped fields.
          $.each(skipped_fields, (idx, field_key) ->
            select = container.find("select[name='goal[curriculum_attributes][" + field_key + "]']")
            current_value = $(select).val().toString()
            info_key = keys_map[field_key]
            options = extra_info[info_key]
            found = false
            # Find if there is any matched value
            for opt in options
              if opt[1].toString() == current_value
                found = true
                break

            if(!found && res.curriculum)
              goal.change_extended_select_value(select, res.curriculum[field_key])
          )

          # Change the options of other fields.
          $.each(fields, (idx, field_key) ->
            info_key = keys_map[field_key]
            options = extra_info[info_key]
            new_options_html = ""
            $.each(options, (idx, data) ->
              name = data[0]
              value = data[1]
              new_options_html += '<option value="' + value + '">' + name + '</option>'
            )
            select = container.find("select[name='goal[curriculum_attributes][" + field_key + "]']")
            select.html(new_options_html)

            if res.curriculum
              # Reset the value of dropdown box
              goal.change_extended_select_value(select, res.curriculum[field_key])
          )

        # Show the current select curriculum
        if(res && res.curriculum)
          curriculum = res.curriculum
          if curriculum.description1
            curriculum_desc.find(".description1").html(curriculum.description1)
          else
            curriculum_desc.find(".description1").html("")
          if curriculum.html_description2
            curriculum_desc.find(".description2").html(curriculum.html_description2)
          else
            curriculum_desc.find(".description2").html("")
          curriculum_desc.removeClass("hide")
          curriculum_desc.find(".error").addClass("hide")
          curriculum_desc.find(".control-label").removeClass("hide")
          # Change curriculum name
          $(curriculum_name).html(curriculum.full_name)
        else if(res && res.error)
          curriculum_desc.find(".error").removeClass("hide").html(res.error)
          curriculum_desc.find(".control-label").addClass("hide")
          curriculum_desc.find(".description1, .description2").html("")
          curriculum_desc.removeClass("hide")
          # Change curriculum name
          $(curriculum_name).html("")
        else
          # Clear the old result
          curriculum_desc.find(".description1, .description2").html("")
          curriculum_desc.addClass("hide")
          curriculum_desc.find(".error").addClass("hide")
          curriculum_desc.find(".control-label").removeClass("hide")
          # Change curriculum name
          $(curriculum_name).html("")        
        
        # Hide the loading
        $(loading).addClass("hide")
    })

  # Change the value of the extended select box
  change_extended_select_value: (select, value) ->
    widget = $(select).data("combobox")
    $(select).val(value)
    opt_name = $(select).find("option:selected").text()
    if widget
      $(widget.wrapper).find(".ui-combobox-input").html(opt_name)    

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


