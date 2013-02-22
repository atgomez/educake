$ ->
  goal.setup()

window.goal =
  setup: ->
    @setup_grade_form()
    @check_on_select_grade()
    @toggle_goal_type()
    return

  setup_grade_form: ->
    $("#student_id").change( ->
      student_id = $.trim($(this).val())
      if(student_id != '')
        $.ajax({
          url: "/goals/load_goals?student_id=" + student_id,
          type: "GET",
          
          complete: (xhr, status ) ->
            if(xhr.status == 200 && xhr.responseText)
              console.log($("#grade_goal_id"))
              $("#grade_goal_id").html(xhr.responseText)
              $("#grade_goal_id").selectmenu( "refresh" );
              goal.toggle_goal_type()
              goal.enable_grade_fields(true)
        })
      else
        goal.enable_grade_fields(false)
    )

    $(".date-picker-ext").datepicker({
      dateFormat: "mm-dd-yy",
      yearRange: "-10:+10",
      changeMonth: true,
      changeYear: true,
      showOn: 'button',
      buttonText: "",
      showButtonPanel: true
    })

    # Add a custom trigger
    trigger = $("#grade_due_date").next(".ui-datepicker-trigger")
    trigger.replaceWith('<div class="ui-button ui-state-default ui-corner-all datepicker-trigger">
                        <span class="ui-icon ui-icon-calculator"></span></div>')

    # Trigger event
    $(".datepicker-trigger").live("click",  ->
      $(".date-picker-ext").datepicker("show")
    )

  enable_grade_fields: (enabled) ->
    selector = $("input[name^='grade['], select[name^='grade['], textarea[name^='grade[']")
    method = ""
    if(enabled)
      method = "enable"
      selector.removeAttr("disabled")
    else
      method = "disable"
      selector.attr("disabled", true)

    $.each(selector, (idx, elem) ->
      if($(elem).is("input") || $(elem).is("textarea"))
        $(elem).textinput(method)
      else if($(elem).is("select"))
        $(elem).selectmenu(method)
    )

  toggle_goal_type: ->
    goal_type = $("#grade_goal_id").find('option:selected').attr('goal_type')
    if goal_type == "true"
      $(".grade-percentage").show()
      $(".grade-objective").hide()
    else
      $(".grade-percentage").hide()
      $(".grade-objective").show()

  check_on_select_grade: ->
    $("#grade_goal_id").live("change", () ->
      goal.toggle_goal_type()
    )
