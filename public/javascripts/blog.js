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
