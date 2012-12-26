$(function() {
  curriculum.setup();
});

curriculum = {
  setup: function(){
    curriculum.setup_comboboxes();
  },

  setup_comboboxes: function(){
    // Init extension methods
    jquery_ext.extend_combobox_widget({
      extend_method_name: "combobox",
      allow_new_value: true
    });

    jquery_ext.extend_combobox_widget({
      extend_method_name: "readonly_combobox",
      editable: false, 
      allow_new_value: false
    });

    $(".editable-combobox").combobox();

    
    $(".extended-combobox").readonly_combobox();
  }
};
