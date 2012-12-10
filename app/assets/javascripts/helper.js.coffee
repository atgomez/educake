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
    $(".not-implemented").click((e) ->
      alert("This feature is coming soon")
    )

  scroll_to: (element, delay_time) ->
    if !delay_time
      delay_time = 300
    $('html, body').animate({ scrollTop: $(element).offset().top - 10}, delay_time)

  # Parse string to Date object.
  # Require: jQuery UI datepicker.
  parse_date: (value, date_format) ->
    result = null
    try
      result = $.datepicker.parseDate(date_format, value);
    catch exc
      result = null
    return result

  clickExport: ->
    $('#export-button').click((e) ->
      e.preventDefault()
      $('#export-dialog').modal('show')
    )

  allowInputNumber: ->
    $('#user_phone').filter_input({regex:'[0-9]'})
    $('#grade_value').filter_input({regex:'[0-9.]', live:true})
    $(".numeric").filter_input({regex:'[0-9.]', live:true})
    $('#user_first_name').filter_input({regex:'[a-zA-Z- ]', live:true})
    $('#user_last_name').filter_input({regex:'[a-zA-Z- ]', live:true}) 
    $('#user_email').filter_input({regex:'[a-zA-Z0-9_.@\r+]', live:true}) 
    $('#student_sharing_first_name').filter_input({regex:'[a-zA-Z- ]', live:true})
    $('#student_sharing_last_name').filter_input({regex:'[a-zA-Z- ]', live:true}) 
    $('#student_sharing_email').filter_input({regex:'[a-zA-Z0-9_.@+]', live:true})
    $('#student_first_name').filter_input({regex:'[a-zA-Z- ]', live:true})
    $('#student_last_name').filter_input({regex:'[a-zA-Z- ]', live:true}) 
    $('.valid_name').filter_input({regex:'[a-zA-Z- ]', live:true})
    $('.valid_email').filter_input({regex:'[a-zA-Z0-9_.@+]', live:true}) 
    $('.valid_number').filter_input({regex:'[0-9]', live:true}) 
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
