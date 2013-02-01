$ ->
  goal.setup()

window.goal =
  setup: ->
    @setup_grade_form()
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
              $("#grade_goal_id").html(xhr.responseText)
              goal.enable_grade_fields(true)
        })
      else
        goal.enable_grade_fields(false)
    )    

  enable_grade_fields: (enabled) ->
    selector = "input[name^='grade['], select[name^='grade['], textarea[name^='grade[']"
    if(enabled)
      $(selector).removeAttr("disabled")
    else
      $(selector).attr("disabled", true)
