$(function() {
  $('.container .table-tasks-popup a').click(function() {
    var $container = $(this).closest('.container');
    $container.find('input[name=mode]').val($(this).attr('rel')).closest('form').submit();
    return false;
  });

  $('.container .table-tasks-popup').hide();
  
  $('.container table input.select-all').click(function() {
    var select_all = this;
    var $container = $(this).closest('.container');
    $container.find('input[type=checkbox]').each(function() { this.checked = select_all.checked; });
  });
  
  $('.container table input[type=checkbox]').click(function() {
    var $container = $(this).closest('.container');
    if (!$(this).hasClass('select-all') && !this.checked) {
      var select_all = $container.find('input.select-all')[0];
      if (select_all.checked && $container.find('tbody input[type=checkbox]').not(':checked').length > 0) {
        select_all.checked = false;
      }
    }
    $container.find('.table-tasks-popup').fadeToggle($container.find('tbody input:checked').length > 0);
  });
  
  $(document).bind('close.facebox', function() {
    for (i in CKEDITOR.instances) {
      CKEDITOR.remove(CKEDITOR.instances[i]);
    };
  });
});
