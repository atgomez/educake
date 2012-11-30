window.schoolObject =
  setup: ->
    @checkForCheckbox()
    @removeClassInForm()
    @limitInput()
    @searchForSuperAdmin()
    @clickOnSubmitAdmin()
  
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
  
  limitInput: ->
    $("#school_zipcode").keypress (event) ->
      key = (if event.charCode then event.charCode else (if event.keyCode then event.keyCode else 0))
      
      if $(this).val().length > 4
        if !(key == 8 || key == 9 || key == 13 || key == 35 || key == 36|| key == 37 || key == 39 || key == 46) 
          event.preventDefault()
    return

  searchForSuperAdmin: ->
    $("#users_search").change ->
      search_type = $(this).val()
      school_id = $("#school").val()
      search_query = $(".search-query").val()
      $.ajax
        type: "GET"
        url: "/super_admin/users/search_result"
        data: {search_type: search_type, query: search_query}
        success: (data)->
          
          if school_id is ""
            window.location.href = "/super_admin/users/search_result?search_type="+search_type+"&query="+search_query
          else
            window.location.href = "/super_admin/users/search_result?search_type="+search_type+"&query="+search_query+"&school="+school_id
          return
        error: (errors, status)->
          
          return
  clickOnSubmitAdmin: ->
    $("#btn_admin").click ->
      email_admin = $("#email_admin").val()
      new_email = $("#user_email").attr("value")
      if email_admin != new_email
        conf = confirm("Do you want to change your email?") 
        if conf is true
          $("#user_form").submit()
    return
    
    
