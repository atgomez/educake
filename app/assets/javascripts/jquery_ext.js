/**
 * Extension methods for jQuery and jQuery UI.
 */
jquery_ext = {
  // Inspired by http://jqueryui.com/autocomplete/#combobox
  extend_combobox_widget: function(options){
    var default_options = {
      extend_method_name: "combobox", // The method name will be called to use this extension
      editable: false, // Allow user to input
      allow_new_value: false // Allow new value input by the user not included in the selection set.
    };
    
    // Clone a new oneto prevent changing default_options
    var tmp_opts = default_options;

    // Initilize default value
    options = $.extend(tmp_opts, options);
    (function( $ ) {
        $.widget( "ui." + options.extend_method_name, {
            _create: function() {
                var input,
                    that = this,
                    select = this.element.hide(),
                    selected = select.children( ":selected" ),
                    value = selected.val() ? selected.text() : "",
                    wrapper = this.wrapper = $( "<span>" )
                        .addClass( "ui-combobox" )
                        .insertAfter( select );

                function removeIfInvalid(element) {
                    var value = $( element ).val(),
                        matcher = new RegExp( "^" + $.ui.autocomplete.escapeRegex( value ) + "$", "i" ),
                        valid = false;
                    select.children( "option" ).each(function() {
                        if ( $( this ).text().match( matcher ) ) {
                            this.selected = valid = true;
                            return false;
                        }
                    });

                    if ( !valid ) {
                        if(options.allow_new_value){
                            // Add invalid value (not included in the selections set)
                            var temp_opt = select.find(".temp-opt");
                            if(!temp_opt || temp_opt.length <= 0){
                              // Add a temporary option.
                              temp_opt = $('<option class="temp-opt"></option>');
                              temp_opt.appendTo(select);
                            }
                            temp_opt.html(value);
                            temp_opt.val(value);
                            tmp = select.val();
                            select.val(value);
                            if(tmp != select.val())
                                select.change();
                        }
                        else {
                            // remove invalid value, as it didn't match anything
                            tmp = select.val();
                            select.val("");
                            if(tmp != select.val())
                                select.change();
                            input.data( "autocomplete" ).term = "";
                        }
                        return false;
                    }
                }

                if(options.editable){
                    input = $( "<input>" ).val( value );
                }
                else {
                    input = $("<span>").html(value);
                }

                input.appendTo( wrapper )
                    .addClass( "ui-state-default ui-combobox-input" )
                    .addClass( "ui-widget ui-widget-content ui-corner-left" )
                    .autocomplete({
                        appendTo: wrapper,
                        delay: 0,
                        minLength: 0,
                        source: function( request, response ) {
                            var matcher = new RegExp( $.ui.autocomplete.escapeRegex(request.term), "i" );
                            response( select.children( "option" ).map(function() {
                                var text = $( this ).text();
                                if ( this.value && ( !request.term || matcher.test(text) ) )
                                    return {
                                        label: text.replace(
                                            new RegExp(
                                                "(?![^&;]+;)(?!<[^<>]*)(" +
                                                $.ui.autocomplete.escapeRegex(request.term) +
                                                ")(?![^<>]*>)(?![^&;]+;)", "gi"
                                            ), "<strong>$1</strong>" ),
                                        value: text,
                                        option: this
                                    };
                            }) );
                        },
                        select: function( event, ui ) {
                            ui.item.option.selected = true;
                            that._trigger( "selected", event, {
                                item: ui.item.option
                            });

                            select.change();
                        },
                        change: function( event, ui ) {
                            if ( !ui.item )
                                return removeIfInvalid( this );
                        },
                        open: function( event, ui ) {
                            // Workaround the set the width of the UI menu.
                            var width = input.outerWidth();
                            width += input.siblings(".ui-combobox-toggle").outerWidth() - 3;
                            var menu = input.data( "autocomplete" ).menu.activeMenu;
                            $(menu).width(width);
                        }
                    });

                input.data( "autocomplete" )._renderItem = function( ul, item ) {
                    return $( "<li>" )
                        .data( "item.autocomplete", item )
                        .append( "<a>" + item.label + "</a>" )
                        .appendTo( ul );
                };

                var hanlder = $('<a class="ui-button ui-widget ui-state-default ui-button-icon-only \
                                  ui-corner-right ui-combobox-toggle" \
                                  role="button" aria-disabled="false"></a>');
                hanlder.html('<span class="ui-button-icon-primary ui-icon ui-icon-triangle-1-s">');
                $(hanlder)
                    .attr( "tabIndex", -1 )
                    .appendTo( wrapper )
                    .click(function() {
                      // close if already visible
                      if ( input.autocomplete( "widget" ).is( ":visible" ) ) {
                        input.autocomplete( "close" );
                        removeIfInvalid( input );
                        return;
                      }

                      // work around a bug (likely same cause as #5265)
                      $( this ).blur();

                      // pass empty string as value to search for, displaying all results
                      input.autocomplete( "search", "" );
                      input.focus();
                    });

                input
                  .tooltip({
                    position: {
                      of: this.button
                    },
                    tooltipClass: "ui-state-highlight"
                  })
                  .click(function() {
                      $(hanlder).click();
                  });

                var _click_handler = function (e) {
                    try {
                        if($(document).has(input).length === 0){
                            // Unbind the event
                            $(document).unbind("mouseup", _click_handler);
                            return;
                        }
                        var menu = $(input).data( "autocomplete" ).menu.activeMenu;
                        if (input.has(e.target).length === 0 ||
                            $(menu).has(e.target).length === 0)
                        {
                            if(!$(e.target).hasClass('ui-autocomplete'))
                                input.autocomplete( "close" );
                            
                        }
                    }
                    catch(e){
                    }
                };

                // Work-around to fix bug when the 'editable' is false
                if(!options.editable){
                    $(document).mouseup(_click_handler);
                }
            },

            destroy: function() {
                this.wrapper.remove();
                this.element.show();
                $.Widget.prototype.destroy.call( this );
            }
        });
    })( jQuery );
  }
};

$(function() {
    // Init extension methods
    jquery_ext.extend_combobox_widget();

    jquery_ext.extend_combobox_widget({
      extend_method_name: "editable_combobox",
      editable: true,
      allow_new_value: true
    });
});
