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

  var forms = ['assignee', 'status', 'priority'];

  for(var i = 0; i < forms.length; i++) {
  
    jQuery('[data-type="' + forms[i] + '"]').click(function(e) {
      e.preventDefault();

      var elem = jQuery(this);
      var type = elem.data('type');      
      var dialog = jQuery('#change-' + type);
      var options = dialog.find('form select');

      /* set ticket id */
      dialog.find('form').attr('action',
          elem.parents('tr').data('ticket-url'));
      

      /* select assigned user */
      options.removeAttr('selected');
      options.find('[value="' + elem.data('id') + '"]').attr('selected', 'selected');

      /* show the dialog */
      dialog.foundation('reveal','open');

    });

  }

});

