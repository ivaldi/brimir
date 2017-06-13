jQuery(function() {

  var current_selection = '';

  jQuery(document).on('mouseup', 'body', function() {
    current_selection = window.getSelection().toString();
  })

  jQuery('.split-off-ticket').bind('click', function(event) {
    if (current_selection != '') {
      var url = jQuery(this).attr('href') + '.json';
      var data = {
        selected_text: current_selection
      };

      jQuery.ajax({
        url: url,
        type: 'post',
        data: data,
        success: function(result) {
          window.location = result.ticket_path;
        }
      });

      return false;
    }
  });
});