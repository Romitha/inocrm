// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require jquery-fileupload/basic
//= require jquery-fileupload/vendor/tmpl
//= require jquery.Jcrop
//= require websocket_rails/main
//= require twitter/bootstrap
//= require bootstrap-editable
//= require bootstrap-editable-rails
//= require jquery_nested_form
//= require bootstrap-datepicker/core
//= require bootstrap-datepicker/locales/bootstrap-datepicker.es
//= bootstrap3-typeahead.min.js
//= require jquery.validate
//= require jquery.validate.additional-methods
//= require moment
//= require bootstrap-datetimepicker
//= require bootstrap-wysihtml5
//= require chosen-jquery
//= require mustache
//= require_tree .
$.fn.editable.defaults.ajaxOptions = {type: "PUT", mode: "inline"};
$.fn.editable.defaults.error = function(response, newValue){
  if(response.status == 500){
    alert(response.responseText);
  }
  else{
    return response.responseText;
  }
}


$.fn.regexMask = function (mask) {
  if (!mask) { 
    throw 'mandatory mask argument missing';
  } 
  else if (mask == 'float-ptbr') { 
    mask = /^((\d{1,3}(\.\d{3})*(((\.\d{0,2}))|((\,\d*)?)))|(\d+(\,\d*)?))$/;
  } 
  else if (mask == 'float-enus') { 
    mask = /^((\d{1,3}(\,\d{3})*(((\,\d{0,2}))|((\.\d*)?)))|(\d+(\.\d*)?))$/;
  }
  else if (mask == 'integer') { 
    mask = /^\d+$/;
  }
  else if (mask == 'after_two_decimal')
    mask = /^\d+(\.\d{1,2})?$/;
  else { 
    try { 
      mask.test("");
    }
    catch(e) { 
      throw 'mask regex need to support test method'; 
    }
  }
  $(this).keypress(function (event) { 
    if (!event.charCode) return true;
    var part1 = this.value.substring(0,this.selectionStart);
    var part2 = this.value.substring(this.selectionEnd,this.value.length);
    if (!mask.test(part1 + String.fromCharCode(event.charCode) + part2))
      return false; 
    }
  ); 
};