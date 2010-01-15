$(function() {
  $('#user_comment').clearOnClick({text:'Type something in here, when you get close to the end the box will expand!...'});
});

(function($){
  $.fn.clearOnClick = function(options) {
      
    var settings = $.extend({}, options);
      
    this.each(function(){
      $(this).css({ color: "#b2adad" }).attr({ value: settings.text }).focus(function(){
        if($(this).val()==settings.text){
          $(this).val("").css({ color: "#333" });
        }
      }).blur(function(){
        if($(this).val()==""){
          $(this).css({ color: "#b2adad" }).val(settings.text);
        }
      });  
    });
    // Chain:
    return this;
  };
})(jQuery);
