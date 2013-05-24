// Brimir is a helpdesk system to handle email support requests.
// Copyright (C) 2012 Ivaldi http:gcivaldi.nl
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <http:gcwww.gnu.org/licenses/>.

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

