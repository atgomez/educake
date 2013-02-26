$ ->
  sadmin_user.setup()

window.sadmin_user =
  setup: ->
    loading = $("#block-user-trigger").siblings(".block-indicator")
    $("#block-user-trigger").live("ajax:before", ->
      loading.removeClass("hide")
      $(this).find("input").attr("disabled", true)
    ).live("ajax:complete", ->
      loading.addClass("hide")
      $(this).find("input").removeAttr("disabled")
    )
