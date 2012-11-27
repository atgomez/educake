window.schoolObject =
  setup: ->
    @checkForCheckbox()
    @removeClassInForm()
  
  checkForCheckbox: ->
    checked = $("#check_locked").val()
    if checked == "true"
      $("#is_locked").attr("checked", "checked")
    else
      $("#is_locked").attr("checked", false)
    return
 
  removeClassInForm: -> 
    $("#school_zipcode").parent().parent().removeClass()
    $("#school_city").parent().parent().removeClass()
    return
