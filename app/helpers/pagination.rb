# Brimir is a helpdesk system to handle email support requests.
# Copyright (C) 2012-2015 Ivaldi http://ivaldi.nl
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

module Pagination
  # Foundation pagination with Font Awesome icons
  class PaginationRenderer < WillPaginate::ActionView::LinkRenderer
    protected

      def gap
        tag :li, link(super, '#'), class: 'unavailable'
      end

      def page_number(page)
        tag :li, link(page, page, rel: rel_value(page)),
            class: ('current' if page == current_page)
      end

      def previous_or_next_page(page, _text, classname)
        tag :li, link('<i class="fa fa-arrow-circle-' +
            (classname == 'previous_page' ? 'left' : 'right') +
            '"></i>', page || '#')
      end

      def html_container(html)
        tag(:ul, html, container_attributes)
      end

      def gap
        tag :li, '<a>...</a>'
      end
  end
end
