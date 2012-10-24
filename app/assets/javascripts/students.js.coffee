
  
window.studentObject =
  setup: ->
    @addDatePicker()
    @clickOnGoal()
    @clickOnStatus()
    @clickOnUsers()
    @activeTab()
    @clickOnStudents() 
    @clickPage()
    @searchUser()
    @autocompleteSearch()
    return

  addDatePicker: ->
    $("#student_birthday").datepicker({"format": "mm-dd-yyyy"})
    return 
  autocompleteSearch: -> 
    $('#student_sharing_email').live "keydown.autocomplete", -> 
      $(this).autocomplete
        source: $(this).data('autocomplete-source')
    return
  searchUser: -> 
    $("#render_invite_user").delegate "#search-email", "click", () ->
      email = $("#student_sharing_email").val()
      student_id = $("#student_sharing_student_id").val()
      console.log email
      $.ajax
        type: "GET"
        url: "/students/"+student_id+"/search_user"
        data: {email: email}
        success: (data)->
          if data["existed"]
            console.log "new user"
          else
            $("#student_sharing_email").attr("value", data["email"])
            $("#student_sharing_first_name").attr("value", data["first_name"])
            $("#student_sharing_last_name").attr("value", data["last_name"])
            $("#student_sharing_role_id").attr("value", data["role_id"])
          return
        error: (errors, status)->
          $(".ajax-loading").addClass "hidden"
          return      
      
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

    
  clickPage: ->
    $("#content-status").delegate('.pagination ul li a', 'click', loadPage)   
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
      
loadPage= (evt) ->
  # Prevent loading page
  evt.preventDefault()
  
  # Mask loading
  #$('#content-status').addClass 'loading'

  sender = evt.target
  
  $.ajax({
    url: sender.href
    type: 'GET'
    success: (data) ->
      $('#content-status').html data
      return
    error: (data) ->
      return
    complete: () ->
      $('#content-status').removeClass 'loading'
  })
  return

