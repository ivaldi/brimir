// Brimir is a helpdesk system to handle email support requests.
// Copyright (C) 2012-2014 Ivaldi http:gcivaldi.nl
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

  jQuery('.ticket input[type="checkbox"]').on('change', function(){
    jQuery(this).parents('.ticket').toggleClass('highlight');
  });

  jQuery('[data-toggle-all]').on('change', function(){
    var checked = this.checked ? true : false;
    jQuery('.ticket input[type="checkbox"]').each(function(){
      if(checked && !this.checked || !checked && this.checked){
        jQuery(this).click();
      }
    });
  });
});