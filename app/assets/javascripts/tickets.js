// Brimir is a helpdesk system to handle email support requests.
// Copyright (C) 2012-2015 Ivaldi http://ivaldi.nl
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

  jQuery('[data-assignee-id]').click(function(e) {
    e.preventDefault();

    var elem = jQuery(this);
    var dialog = jQuery('#change-assignee');
    var options = dialog.find('form select');

    /* set ticket id */
    dialog.find('form').attr('action',
      elem.parents('tr').data('ticket-url'));

      /* select assigned user */
      options.removeAttr('selected');
      options.find('[value="' + elem.data('assignee-id') + '"]').attr('selected', 'selected');

      /* show the dialog */
      dialog.foundation('reveal','open');

  });

  jQuery('[data-set-time-consumed]').click(function(e) {
    e.preventDefault();

    var elem = jQuery(this);
    var dialog = jQuery('#set-time-consumed');

    var days_select = dialog.find('form select#ticket_consumed_days');
    var hours_select = dialog.find('form select#ticket_consumed_hours');
    var minutes_select = dialog.find('form select#ticket_consumed_minutes');

    var days = parseInt(elem.data('set-time-consumed').split('-')[0]);
    var hours = parseInt(elem.data('set-time-consumed').split('-')[1]);
    var minutes = parseInt(elem.data('set-time-consumed').split('-')[2]);

    /* set ticket url */
    dialog.find('form').attr('action', elem.parents('tr').data('ticket-url'));

    days_select.select2('val', days);
    hours_select.select2('val', hours);
    minutes_select.select2('val', minutes);

    /* show the dialog */
    dialog.foundation('reveal','open');
  });

});
