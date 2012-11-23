window.schoolObject =
  setup: ->
    @checkForCheckbox()
  
  checkForCheckbox: ->
    checked = $("#check_locked").val()
    if checked == "true"
      $("#is_locked").attr("checked", "checked")
    else
      $("#is_locked").attr("checked", false)
    return
