window.studentObject =
  setup: ->
    @addDatePicker()
    @clickOnGoal()
    @clickOnStatus()
    @clickOnUsers()
    @activeTab()
    @clickOnStudents() 
    return

  addDatePicker: ->
    $("#student_birthday").datepicker({"format": "mm-dd-yyyy"})
  
  clickOnGoal: -> 
    $(".status").delegate 'a.goal', 'click', () -> 
      id_content = $(this).attr("href")
      cl = $(this).attr("class").split("goal").join("").trim()
      if cl == "icon-plus"
        $(this).removeClass("icon-plus").addClass("icon-minus")
        $(id_content).attr("style","display:block;")
        console.log $(id_content)
      else if cl == "icon-minus"
        $(this).removeClass("icon-minus").addClass("icon-plus")
        $(id_content).attr("style","display:none;")
      return
  
  activeTab: ->
    if $("#tab").val() == "user"
      $("#users").addClass("active")
      $("#status").removeClass("active")
      loadUser()
    return

  clickOnStatus: ->
    $("#status").click ->
      $(this).addClass("active")
      $("#users").removeClass("active")
      $.ajax
        type: "GET"
        url: $("#student_id").val()+"/load_status"
        data: {}
        success: (data)->
          $(".status").attr("style","display:block")
          $(".users").attr("style","display:none")
          $("#content-status").html(data)
          return
        error: (errors, status)->
          $(".ajax-loading").addClass "hidden"
          return      
  
  clickOnUsers: -> 
    $("#users").click ->
      $(this).addClass("active")
      $("#status").removeClass("active")
      loadUser()
      return
      
    $("#show_user").click ->
     $("#users").addClass("active")
     $("#status").removeClass("active")
     loadUser()
     return

  clickOnStudents: ->
    $(".student-container .link").click ->
      url = $(this).attr('href')
      if $.trim(url) != ''
        window.location.href = url

loadUser = ->
  $.ajax
    type: "GET"
    url: $("#student_id").val()+"/load_users"
    data: {}
    success: (data)->
      $(".users").attr("style","display:block")
      $(".status").attr("style","display:none")
      $("#content-users").html(data)
      return
    error: (errors, status)->
      $(".ajax-loading").addClass "hidden"
      return
