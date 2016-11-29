# Brimir is a helpdesk system to handle email support requests.
# Copyright (C) 2012-2015 Ivaldi https://ivaldi.nl/
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

# helpers used system wide
module ApplicationHelper
  def active_elem_if(elem, condition, attributes = {}, &block)
    if condition
      # define class as empty string when no class given
      attributes[:class] ||= ''
      # add 'active' class
      attributes[:class] += ' active'
    end

    # return the content tag with possible active class
    content_tag(elem, attributes, &block)
  end

  # change the default link renderer for will_paginate
  def will_paginate(collection_or_options = nil, options = {})
    if collection_or_options.is_a? Hash
      options, collection_or_options = collection_or_options, nil
    end
    unless options[:renderer]
      options = options.merge renderer: Pagination::PaginationRenderer
    end
    super(*[collection_or_options, options].compact)
  end

  def tabindex
    @tabindex ||= 0
    @tabindex += 1
  end

  def custom_time_select(object, method, attributes={}, options={})
    return if object.nil?

    attributes[:default] ||= ''
    attributes[:name] ||= ''
    attributes[:id] ||= ''

    options[:minutes] ||= false
    options[:military] ||= true

    if options[:military]
      range = 0..23
    else
      range = 0..11
    end

    result = object.try(:send, method)
    result = result.hour if result.kind_of?(DateTime) || result.kind_of?(Time)
    has_value = range.include?(result)

    content_tag(:select, name: attributes[:name], id: attributes[:id]) do
      result = "#{result}:00" if options[:minutes]
      range.each do |e|
        e = "#{e}:00" if options[:minutes]
        if has_value && e == result
          concat content_tag(:option, e, selected: :selected)
        elsif e == options[:default]
          concat content_tag(:option, e, selected: :selected)
        else
          concat content_tag(:option, e)
        end
      end
    end
  end

end
