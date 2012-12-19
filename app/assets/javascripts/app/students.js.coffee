$ ->
  studentObject.setup()

window.chartMode = 'view_all'

window.chartLoaded= (chart) ->
  $(chart.series).each((idx, item) ->
    $('#goal' + item.options.item_id).attr('color', item.color.replace('#', ''))
  )
window.clickOnChart= ->
  if (window.chartMode == 'view_goal')
    $('a.goal').each ->
      id_content = $(this).attr("href")
      $(this).removeClass("icon-minus").addClass("icon-plus")
      $(id_content).slideUp('fast', ->
        $(id_content).attr("style","display:none;")
      )
      $('#chart').attr("src", "/charts/student_chart?student_id="+ $("#student_id").val() + "&user_id=" + $("#user_id").val());
      window.chartMode = 'view_all'

window.studentObject =
  setup: ->
    @clickOnGrade()
    @clickOnStudents() 
    @clickPage()
    @searchUser()
    @autocompleteSearch()
    @uploadPhoto()
    @onSaveInvitation()
    @scrollToUser()
    @timeForField()
    @checkClassroom()
    @disableSubmitForm()
    @addBirthDayPicker()
    return
    
  checkClassroom: ->
    $(".export_data_selector").change ->
      if @value is "classroom"
        $("#student_selection").attr("disabled", "disabled")
      else if @value is "school"
        $("#student_selection").attr("disabled", "disabled")
        $("#teacher_selection").attr("disabled", "disabled")
      else
        $("#student_selection").removeAttr("disabled")
        $("#teacher_selection").removeAttr("disabled")

  timeForField: ->
    $('#grade_time_to_complete').live "focus", ->
      $(this).timepicker 
        hourGrid: 4,
        minuteGrid: 10
      return

  uploadPhoto: ->
    $('#student_photo').change((e) ->
      file = e.target.files[0]
      console.log(e.target.files)
      reader = new FileReader()
      reader.onload = (e) ->
        img = $('#upload-image')
        img.attr('width', '')
        img.attr('height', '')
        img.css('width', '')
        img.css('height', '')
        img.css('margin-top', '')
        img.css('margin-left', '')
        img.attr('src', e.target.result).load(() ->
          console.log('Image loaded')
          h = $(this).height()
          w = $(this).width()
          
          console.log('Start cropping image with ' + w + 'px width and ' + h + 'px height')
          if (h > w) 
            $(this).css('width', 200)
            h = $(this).height()
            $(this).css('margin-top', (200 - h)/2)
          else
            $(this).css('height', 200)
            w = $(this).width()
            $(this).css('margin-left', (200 - w)/2)
        )

      reader.readAsDataURL(file)
    )

  autocompleteSearch: -> 
    disable_elements = (disabled) ->
      $("#student_sharing_first_name, 
          #student_sharing_last_name, 
          #student_sharing_role_id").attr("disabled", disabled)

    $('#student_sharing_email').live "keydown.autocomplete", -> 
      $(this).autocomplete
        source: $(this).data('autocomplete-source')
        search: (event, ui) ->
          disable_elements(false)
        select: (event, ui) ->
          disable_elements(true)
    return

  addBirthDayPicker: ->
    $(".birthday-picker").livequery( ->
      $(this).datepicker({
        dateFormat: "mm-dd-yy",
        yearRange: "-40:+0",
        changeMonth: true,
        changeYear: true
      })
    )

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
          search_email = data["email"]
          $("#student_sharing_email").attr("value", data["email"])
          $("#student_sharing_first_name").attr("value", data["first_name"])
          $("#student_sharing_first_name").attr("disabled", data["disable"])

          $("#student_sharing_last_name").attr("value", data["last_name"])
          $("#student_sharing_last_name").attr("disabled", data["disable"])

          $("#student_sharing_role_id").attr("value", data["role_id"])
          $("#student_sharing_role_id").attr("disabled", data["disable"])

          return
        error: (errors, status)->
          $(".ajax-loading").addClass "hidden"
          return
       if search_email != email 
         $("#student_sharing_role_id").attr("disabled", false)
      
  
    
  clickPage: ->
    $("#content-grade").delegate '#goals_pages .pagination ul li a', 'click', (evt)-> 
      helper.loadPage(evt, "#content-grade")

    $("#content-grade .grades-container .pagination ul li a").live "click", (evt) ->
      evt.preventDefault()
      helper.loadPage(evt, $(this).parents(".grades-container"))
    return 
   
  clickOnGrade: ->
    $("#grade").click (e) ->
      e.preventDefault()
      $(this).addClass("active")
      $("#users").removeClass("active")
      $.ajax
        type: "GET"
        url: $("#student_id").val()+"/load_grade"
        data: {}
        success: (data)->
          $(".grade").attr("style","display:block")
          $(".users").attr("style","display:none")
          $("#content-grade").html(data)
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

  clickOnStudents: ->
    $(".student-container.link, .student-container .link, .teacher-container.link, .teacher-container .link").live('click',  ->
      url = $(this).attr('href')
      if $.trim(url) != ''
        window.location.href = url
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
