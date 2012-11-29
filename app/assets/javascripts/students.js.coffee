
window.chartMode = 'view_all'

window.chartLoaded= (chart) ->
  $(chart.series).each((idx, item) ->
    $('#goal' + item.options.item_id).attr('color', item.color.replace('#', ''))
  )
window.clickOnChart= ->
  if (window.chartMode == 'view_goal')
    $('.goal').each ->
      id_content = $(this).attr("href")
      $(this).removeClass("icon-minus").addClass("icon-plus")
      $(id_content).slideUp('fast', ->
        $(id_content).attr("style","display:none;")
      )
      page_id = ""
      href = $(".pagination li.active a").attr("href")
      if href
        page_id = href.split("?")[1]
      $('#chart').attr("src", "/students/"+ $("#student_id").val() + "/common_chart?"+page_id);
      window.chartMode = 'view_all'

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
    @uploadPhoto()
    @clickExport()
    @onSaveInvitation()
    @scrollToUser()
    @allowInputNumber()
    @timeForField()
    @checkClassroom()
    @disableSubmitForm()
    return
    
  checkClassroom: ->
    $("input[name=data]").change ->
      if @value is "classroom"
        $("#student_selection").attr("disabled", "disabled")
      else
        $("#student_selection").removeAttr("disabled")

  timeForField: ->
    $('#status_time_to_complete').live "focus", ->
      $(this).timepicker 
        hourGrid: 4,
        minuteGrid: 10
      return
  
  allowInputNumber: ->
    $('#user_phone').filter_input({regex:'[0-9]'})
    $('#status_value').filter_input({regex:'[0-9.]', live:true})
    $(".numeric").filter_input({regex:'[0-9.]', live:true})
    $('#user_first_name').filter_input({regex:'[a-zA-Z- ]', live:true})
    $('#user_last_name').filter_input({regex:'[a-zA-Z- ]', live:true}) 
    $('#user_email').filter_input({regex:'[a-zA-Z0-9_.@\r]', live:true}) 
    $('#student_sharing_first_name').filter_input({regex:'[a-zA-Z- ]', live:true})
    $('#student_sharing_last_name').filter_input({regex:'[a-zA-Z- ]', live:true}) 
    $('#student_sharing_email').filter_input({regex:'[a-zA-Z0-9_.@]', live:true})
    $('#student_first_name').filter_input({regex:'[a-zA-Z- ]', live:true})
    $('#student_last_name').filter_input({regex:'[a-zA-Z- ]', live:true}) 
    $('.valid_name').filter_input({regex:'[a-zA-Z- ]', live:true})
    $('.valid_email').filter_input({regex:'[a-zA-Z0-9_.@]', live:true}) 
    $('.valid_number').filter_input({regex:'[0-9]', live:true}) 
    return

  uploadPhoto: ->
    $('#student_photo').change((e) ->
      file = e.target.files[0]
      reader = new FileReader()
      reader.onload = (e) ->
        img = $('#upload-image')
        img.attr('width', '')
        img.attr('height', '')
        $('#upload-image').attr('src', e.target.result)
        h = img.height()
        w = img.width()
        img.css('width', '')
        img.css('height', '')
        
        if (h > w) 
          img.css('width', 200)
        else
          img.css('height', 200)
        w = img.width()
        img.css('margin-left', (200 - w)/2)

      reader.readAsDataURL(file)
    
    )

  addDatePicker: ->
    $("#student_birthday").datepicker({
      dateFormat: "mm-dd-yy",
      yearRange: "-40:+0",
      changeMonth: true,
      changeYear: true
    })
    return 

  autocompleteSearch: -> 
    $('#student_sharing_email').live "keydown.autocomplete", -> 
      $(this).autocomplete
        source: $(this).data('autocomplete-source')
    return

  searchUser: -> 
    email = $("#student_sharing_email").attr("value")
    search_email = ""
    $("#render_invite_user").delegate "#search-email", "click", () ->
      email = $("#student_sharing_email").val()
      student_id = $("#student_sharing_student_id").val()
      $.ajax
        type: "GET"
        url: "/students/"+student_id+"/search_user"
        data: {email: email}
        success: (data)->
          if data["existed"]
            console.log "new user"
          else
            search_email = data["email"]
            $("#student_sharing_email").attr("value", data["email"])
            $("#student_sharing_first_name").attr("value", data["first_name"])
            $("#student_sharing_last_name").attr("value", data["last_name"])
            $("#student_sharing_role_id").attr("value", data["role_id"])
            $("#student_sharing_role_id").attr("disabled", data["disable"])
          return
        error: (errors, status)->
          $(".ajax-loading").addClass "hidden"
          return
       if search_email != email 
         $("#student_sharing_role_id").attr("disabled", false)
      
  clickOnGoal: -> 
    $(".status a.goal").live 'click', () -> 
      page_id = ""
      href = $(".pagination li.active a").attr("href")
      if href
        page_id = href.split("?")[1]

      id_content = $(this).attr("href")
      id = id_content.split("_")[1]
      current_iframe = $('#chart').attr("src")
      id_content = $(this).attr("href")
      if $(this).hasClass("icon-plus")
        $(this).removeClass("icon-plus").addClass("icon-minus")
        $(id_content).slideDown('fast', ->
          $(id_content).attr("style","display:block;")
        )
        loadGrades(id)
        $('#chart').attr("src", "/students/chart?goal_id="+id + "&color=" + $(this).attr('color'));
        $('#chart').attr("height", "500");
        $('#chart').attr("width", "100%");
        $(".status a.goal").each ->
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
        $('#chart').attr("src", "/students/"+ $("#student_id").val() + "/common_chart");
        window.chartMode = 'view_all'
      return
  
  activeTab: ->
    if $("#tab").val() == "user"
      $("#users").addClass("active")
      $("#status").removeClass("active")
      loadUser()
    return

    
  clickPage: ->
    $("#content-status").delegate '#goals_pages .pagination ul li a', 'click', (evt)-> 
      loadPage(evt, "#content-status")

    $("#content-status .grades-container .pagination ul li a").live "click", (evt) ->
      evt.preventDefault()
      loadPage(evt, $(this).parents(".grades-container"))
    return 
   
  clickOnStatus: ->
    $("#status").click (e) ->
      e.preventDefault()
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
    return false
  
  scrollToUser: ->
    $("#goto-users").click((e) ->
      e.preventDefault()
      helper.scroll_to(".users.student-users")
    )

  clickOnUsers: -> 
    $("#users").click (e) ->
      e.preventDefault()
      $(this).addClass("active")
      $("#status").removeClass("active")
      loadUser()
      return
      
    $("#show_user").click ->
     $("#users").addClass("active")
     $("#status").removeClass("active")
     loadUser()
     return
    return false

  clickOnStudents: ->
    $(".student-container.link, .student-container .link").click ->
      url = $(this).attr('href')
      if $.trim(url) != ''
        window.location.href = url

  clickExport: ->
    $('#export-button').click((e) ->
      e.preventDefault()
      $('#export-dialog').modal('show')
    )

  onSaveInvitation: ->
    $('#invite_user form').live('submit', -> 
      $(this).find('.submit-indicator').removeClass('hide')
    )
  disableSubmitForm: ->
    $("#import").live "click", () -> 
      $(this).submit()
      $(this).attr("disabled", "disabled")
    return

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
      
loadPage= (evt, element) ->
  # Prevent loading page
  evt.preventDefault()
  
  # Mask loading
  #$('#content-status').addClass('loading')
  sender = evt.target
  $.ajax({
    url: sender.href
    type: 'GET'
    success: (data) ->
      $(element).html(data)
      return
    error: (data) ->
      return
    complete: () ->
      $('#content-status').removeClass 'loading'
  })
  return

loadGrades= (id) ->
  $.ajax({
    url: "/students/load_grades",
    type: 'GET',
    data: {goal_id: id},
    success: (res) ->
      return
    ,
    error: (data) ->
      return
    ,
    complete: (res) ->
      $('#goal_' + id).find('.grades-container').html(res.responseText)
      return
  })
  return

