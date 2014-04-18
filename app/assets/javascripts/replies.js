jQuery(function() {

  jQuery('a[href=#preview]').click(function(e) {
    var form = jQuery(this).parents('form');
    jQuery.ajax({
      url: '/previews/new',
      type: 'get',
      data: {
        content: form.find('textarea').val(),
      },
      success: function(data) {
        jQuery('#preview').html(data);
      }
    });
  });

});
