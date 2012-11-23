jQuery(function() {

  jQuery('table tr td.assignee a').click(function(e) {
    e.preventDefault();

    var dialog = jQuery('#assign-ticket');
    var options = dialog.find('form select');

    /* set ticket id */
    dialog.find('form').attr('action',
        jQuery(this).parents('tr').data('ticket-url'));
    

    /* select assigned user */
    options.removeAttr('selected');
    options.find('[value="' + jQuery(this).data('assignee-id') + '"]').attr('selected', 'selected');

    /* show the dialog */
    dialog.reveal();

  });

  jQuery('table tr td.status a').click(function(e) {
    e.preventDefault();

    var dialog = jQuery('#change-status');
    var options = dialog.find('form select');

    /* set ticket id */
    dialog.find('form').attr('action',
        jQuery(this).parents('tr').data('ticket-url'));
    

    /* select current status */
    options.removeAttr('selected');
    options.find('[value="' + jQuery(this).data('status-id') + '"]').attr('selected', 'selected');

    /* show the dialog */
    dialog.reveal();

  });
});

