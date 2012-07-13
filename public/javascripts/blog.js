$(function() {
  $.ui.marquess.commands['link'].fn = function(editor) {
    html = $('<div class="marquess-dialog breeze-form"><fieldset><ol class="form"><li class="text_field"><label for="marquess_link_text">Link text<abbr title="required">*</abbr></label><input class="text_field" name="link_text" id="marquess_link_text" /></li><li class="text_field"><label for="marquess_link_url">URL<abbr title="required">*</abbr></label><input class="text_field" name="link_url" id="marquess_link_url" /></li><ul id="marquess_link_select"></ul></div>');
    $(html).dialog({
      title:     'Insert a link',
      width:     480,
      modal:     true,
      resizable: false,
      buttons:   {
        'OK': function() {
          url = $('#marquess_link_url').val();
          if (url[0] != '/' && !(/^https?:\/\//.test(url))) {
            url = 'http://' + url;
          }
          editor.transform({
            defaultText: 'link text',
            text: $('#marquess_link_text').val(),
            before: '[',
            after: '](' + url + ')',
            inline: true
          });
          $(this).dialog("close");
        },
        'Cancel': function() {
          $(this).dialog("close");
        }
      },
      close: function() {
        $(this).remove();
      }
    });
    $('#marquess_link_text').val(editor.editor.selectedText()).each(function() { this.focus(); });
    $('#marquess_link_select').load('/admin/pages/list', function() {
      $('a', this).click(function() {
        if ($('#marquess_link_text').val() == '') { $('#marquess_link_text').val($(this).text()); }
        $('#marquess_link_url').val($(this).attr('href'));
        return false;
      });
      $('li.open, li.closed').click(function() {
        $(this).toggleClass('open').toggleClass('closed');
        return false;
      }).filter('.open').click();
    });
    $('#marquess_link_text, #marquess_link_url').keypress(function(e) {
      if (e.which == 13) {
        $('button:contains(OK)', $(this).closest('.ui-dialog')).click();
        return false;
      }
    });
  };
});

/*
Script: GrowingInput.js
	Alters the size of an input depending on its content

	License:
		MIT-style license.

	Authors:
		Guillermo Rauch
*/

(function($){

$.GrowingInput = function(element, options){
	
	var value, lastValue, calc;
	
	options = $.extend({
		min: 0,
		max: null,
		startWidth: 15,
		correction: 15
	}, options);
	
	element = $(element).data('growing', this);
	
	var self = this;
	var init = function(){
		calc = $('<span></span>').css({
			'float': 'left',
			'display': 'inline-block',
			'position': 'absolute',
			'left': -1000
		}).insertAfter(element);
		$.each(['font-size', 'font-family', 'padding-left', 'padding-top', 'padding-bottom', 
		 'padding-right', 'border-left', 'border-right', 'border-top', 'border-bottom', 
		 'word-spacing', 'letter-spacing', 'text-indent', 'text-transform'], function(i, p){				
				calc.css(p, element.css(p));
		});
		element.blur(resize).keyup(resize).keydown(resize).keypress(resize);
		resize();
	};
	
	var calculate = function(chars){
		calc.text(chars);
		var width = calc.width();
		return (width ? width : options.startWidth) + options.correction;
	};
	
	var resize = function(){
		lastValue = value;
		value = element.val();
		var retValue = value;		
		if(chk(options.min) && value.length < options.min){
			if(chk(lastValue) && (lastValue.length <= options.min)) return;
			retValue = str_pad(value, options.min, '-');
		} else if(chk(options.max) && value.length > options.max){
			if(chk(lastValue) && (lastValue.length >= options.max)) return;
			retValue = value.substr(0, options.max);
		}
		element.width(calculate(retValue));
		return self;
	};
	
	this.resize = resize;
	init();
};

var chk = function(v){ return !!(v || v === 0); };
var str_repeat = function(str, times){ return new Array(times + 1).join(str); };
var str_pad = function(self, length, str, dir){
	if (self.length >= length) return this;
	str = str || ' ';
	var pad = str_repeat(str, length - self.length).substr(0, length - self.length);
	if (!dir || dir == 'right') return self + pad;
	if (dir == 'left') return pad + self;
	return pad.substr(0, (pad.length / 2).floor()) + self + pad.substr(0, (pad.length / 2).ceil());
};

})(jQuery);

