$ ->
  mobile_helper.setup()

window.mobile_helper = 
  setup: ->
    @add_date_picker()

  add_date_picker: ->
    $(".date-picker").livequery( ->
      $(this).datepicker({
        dateFormat: "mm-dd-yy",
        yearRange: "-10:+10",
        changeMonth: true,
        changeYear: true
      })
    )
