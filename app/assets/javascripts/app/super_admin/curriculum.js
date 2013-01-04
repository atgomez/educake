$(function() {
  curriculum.setup();
});

curriculum = {
  setup: function(){
    curriculum.setup_comboboxes();
    curriculum.setup_validations();
    curriculum.setup_import_form();
  },

  setup_comboboxes: function(){
    $(".editable-combobox").editable_combobox();   
    $(".extended-combobox").combobox();
  },

  setup_validations: function(){
    $(".reset-on-changed").change(function(e) {
      // Reset the client-side validation states.
      $(".curriculum-form").resetClientSideValidations();
    });
  },

  setup_import_form: function(){
    $('#import-container form').live('submit', function(){
      $(this).find('.submit-indicator').removeClass('hide');
    });
  }
};
