window.helper = 
  alert_not_implement: () ->
    $(".not-implemented").click((e) ->
      alert("This feature is coming soon")
    )
