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

# helper functions to convert html mail to text mail and back
module HtmlTextHelper
  def strip_inline_style(content)
    content.gsub(/<style[^>]*>[^<]*<\/style>/, '')
  end

  def html_to_text(content)
    content = strip_inline_style(content).gsub(%r{(<br ?/?>|</p>)}, "\n")
    CGI.unescapeHTML(sanitize(content, tags: []).to_str) # to_str for Rails #12672
  end

  def text_to_html(content)
    CGI.escapeHTML(content).gsub("\n", '<br />')
  end

  def sanitize_html(content)
    # strip inline style tags completely
    sanitize(
        strip_inline_style(content),
        tags:       %w( a b br code div em i img li ol p pre table td tfoot
                        thead tr span strong ul font ),
        attributes: %w( src href style color )
    ).html_safe
  end

  def wrap_and_quote(content)
    content = html_to_text(content)
    content = content.gsub(/^.*\n>.*$/, '') # strip off last line before older quotes
    content = content.gsub(/^>.*$/, '') # strip off older quotes
    content = word_wrap(content.strip, line_width: 72)
    content.gsub(/^/, '> ')
  end
end
