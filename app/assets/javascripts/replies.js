jQuery(function() {
  //jQuery(document).on('click', '.split-off-ticket', function(event) {
  jQuery('.split-off-ticket').bind('click', function(event) {
    if (window.getSelection().toString() != "") {
      var url = $(this).attr('href') + ".json";
      var data = {
        selected_text: window.getSelection().toString()
      }

      jQuery.ajax({
        url: url,
        type: 'post',
        data: data,
        success: function(result) {
          window.location = result.ticket_path;
        }
      });

      event.stopPropagation();
      event.preventDefault();
      return false;
    }
  });
});