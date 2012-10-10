window.studentObject =
  setup: ->
    @addDatePicker()
    return
    
  addDatePicker: ->
    $("#student_birthday").datepicker({"format": "dd-mm-yyyy"})
