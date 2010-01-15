$(function() {
  $('.ExclusiveCheckboxes input').exclusiveCheck();
});

/*
* Exclusive Check Plugin v1.0.1
* Copyright (c) James Westgate
*
* @requires jQuery v1.3.2
*
* Dual licensed under the MIT and GPL licenses:
*   http://www.opensource.org/licenses/mit-license.ph
*   http://www.gnu.org/licenses/gpl.html
*
*/

//Create closure
(function($) {

    //Plugin definition
    $.fn.extend({

        exclusiveCheck: function(options) {

            var selector = $(this);

            //Loop through each item in the matched set and apply event handlers
            return this.each(function(i) {

                //When the checkbox gets clicked, uncheck other checkboxes
                $(this).click(function(event) {

                    var clicked = this;

                    //Uncheck all except current
                    if (this.checked) {
                        selector.each(function() {
                            if (this != clicked) this.checked = false;
                        });
                    }
                });
            });
        }
    });

// end of closure
})(jQuery);
