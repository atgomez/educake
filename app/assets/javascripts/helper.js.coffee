$ ->
  helper.setup()

window.selectGoal= (goal_id, url) ->
  if (url.search('#') == -1)
    window.location = url
  else
    $('#goal' + goal_id).click()

window.helper = 
  setup: ->
    @alert_not_implement()
    @clickExport()
    @allowInputNumber()
    @addDatePicker()

  alert_not_implement: () ->
    $(".not-implemented").live('click', (e) ->
      alert("This feature is coming soon")
    )

  scroll_to: (element, delay_time, container) ->
    if !container
      container = 'html, body'
    if !delay_time
      delay_time = 300
    $(container).animate({ scrollTop: $(element).offset().top - 10}, delay_time)

  # Parse string to Date object.
  # Require: jQuery UI datepicker.
  parse_date: (value, date_format) ->
    result = null
    try
      result = $.datepicker.parseDate(date_format, value);
    catch exc
      result = null
    return result

  # Build a <div> element that contain alert message
  #
  # === params
  #   type (String): can be: success, error, info
  #   message (String): the message to show, this can be a raw text or HTML.
  #
  create_message_panel: (type, message) ->
    div = $('<div data-alert="alert" class="alert fade in">' +
                '<a href="#" data-dismiss="alert" class="close">&times;</a></div>')
    $(div).addClass("alert-" + type)
    $(div).append(message)
    return $(div)

  # Show a message panel to container (#flash) element.
  #
  # === params
  #   type (String): can be: success, error, info
  #   message (String): the message to show, this can be a raw text or HTML.
  #   append (Bool): true/false to determine the message will be appended to the container
  #                  or replace the content of container.
  #   container (String/Selector): the container to include the message. The default selector is #flash.
  #
  flash_message: (type, message, append, container) ->
    msg = helper.create_message_panel(type, message);
    
    if(!container)
      container = "#flash"

    $(container).hide()

    if(append)
      $(container).append(msg)
    else
      $(container).html(msg)

    $(container).fadeIn()

  # Show a warning message when navigating away without saving form data.
  # This function use the 'beforeunload' event.
  #
  # === params
  #   options[form] (selector) (optional): form selector. Default is "form"
  #   options[message] (String) (optional): the message to show. 
  #      Please note that some modern browsers will not allow us customize the message for beforeunload event.
  #      So sometimes this message will not take effect.
  #   options[extra_handler] (function object) (optional): extra handler will be call when the message was showed.
  #
  unsaved_form_message: (options) ->
    changed = false

    default_options = {
      form: "form",
      message: "You have entered new data on this page. Are you sure you want leave this page and lose it all ?",
      extra_handler: null
    }
    
    # Clone a new oneto prevent changing default_options
    tmp_opts = default_options
    # Initilize default value
    options = $.extend(tmp_opts, options)

    $(options.form).find('input, textarea, select').live('change', ->
      changed = true
    )

    $(window).bind('beforeunload', ->
      if(changed)
        if(options.extra_handler)
          options.extra_handler()
        return options.message;
    )

  clickExport: ->
    $('#export-button').live('click', (e) ->
      e.preventDefault()
      $('#export-dialog').modal('show')
    )

  allowInputNumber: ->
    $('#user_phone').filter_input({regex:'[0-9\r\n]', live:true})
    $('#grade_value').filter_input({regex:'[0-9.\r\n]', live:true})
    $(".numeric, .float_number").filter_input({regex:'[0-9.\r\n]', live:true})    
    $("#user_first_name, #user_last_name").filter_input({regex:'[a-zA-Z- \r\n]', live:true})
    $("#student_sharing_first_name, #student_sharing_last_name").filter_input({regex:'[a-zA-Z- \r\n]', live:true})
    $("#student_first_name, #student_last_name").filter_input({regex:'[a-zA-Z- \r\n]', live:true})
    $("#user_email, #student_sharing_email, .valid_email").filter_input({regex:'[a-zA-Z0-9_.@+\r\n]', live:true}) 
    $('#user_classroom').filter_input({regex:'[a-zA-Z0-9- \r\n]', live:true})    
    $('.valid_name').filter_input({regex:'[a-zA-Z0-9- \r\n]', live:true})
    $('.valid_number').filter_input({regex:'[0-9\r\n]', live:true})
    $('#school_name, #school_address1, #school_address2, #school_city').filter_input({regex:'[a-zA-Z0-9- \r\n]', live:true})
    $('.simple_form.curriculum-form input.ui-combobox-input').filter_input({regex:'[a-zA-Z0-9- \r\n]', live:true})
    $('#new_curriculum_import input.ui-combobox-input').filter_input({regex:'[a-zA-Z0-9- \r\n]', live:true})
    $('.goal-form .accuracy').filter_input({regex:'[0-9.\r\n]', live:true})

    return

  addDatePicker: ->
    $(".date-picker").livequery( ->
      $(this).datepicker({
        dateFormat: "mm-dd-yy",
        yearRange: "-10:+10",
        changeMonth: true,
        changeYear: true
      })
    )
    if ($.browser.msie) 
      $(".ui-datepicker .ui-state-highlight").livequery( () -> 
        $(this).attr("style", "margin-bottom:0px;")
      )


  loadPage: (evt, element) ->
    # Prevent loading page
    evt.preventDefault()
    
    # Mask loading
    #$('#content-grade').addClass('loading')
    sender = evt.target
    url = sender.href
    if url.indexOf("grade_id") > 0
      grade_id = url.split("&")[1]
      url = url.replace(grade_id, "")

    $.ajax({
      url: url
      type: 'GET'
      success: (data) ->
        $(element).html(data)
        return
      error: (data) ->
        return
      complete: () ->
        $('#content-grade').removeClass 'loading'
    })
    return

  loadGrades: (id, page_id, grade_id = 0) ->
    if grade_id != 0
      data = {goal_id: id, grade_id:grade_id}
    else
      data = {goal_id: id}
    $.ajax({
      url: "/goals/load_grades",
      type: 'GET',
      data: data,
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

  deleteGrade: (goal_id, grade_id) ->
    $.ajax({
      url: "/goals/delete_grade",
      type: 'GET',
      data: {goal_id: goal_id, grade_id:grade_id},
      success: (res) ->
        return
      ,
      error: (data) ->
        return
      ,
      complete: (res) ->
        $('#goal_' + goal_id).find('.grades-container').html(res.responseText)
        return
    })
    return

  rand_num: () ->
    str_num = Math.random().toString()
    str_num = str_num.replace("0.", "")
    return parseInt(str_num)
