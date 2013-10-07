jQuery(function() {
  
  jQuery('a[href=#preview]').click(function(e) {
    var form = jQuery('#new_reply');
    jQuery.ajax({
      url: form.attr('action'),
      type: 'post',
      data: {
        reply: {
          content: form.find('#reply_content').val()
        }
      },
      success: function(data) {
        var html = jQuery(data).find('#previewTab').html();

        jQuery('#previewTab').html(html);
      }
    });
  });

});
