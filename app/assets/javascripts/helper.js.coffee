window.helper = 
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

