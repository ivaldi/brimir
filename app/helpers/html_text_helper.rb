module HtmlTextHelper

  def html_to_text(content)
    content = sanitize(content.gsub(/(<br( )?\/>|<\/p>)/, "\n"), tags: [])
    content = content.gsub(/<br( )?\/>/, "\n")
    content = content.gsub(/<\/p>/, "\n\n")
    sanitize(content, tags: [])
  end

  def text_to_html(content)
    content.gsub("\n", '<br />')
  end

  def sanitize_html(content)
    sanitize(content, tags: %w(a b br code div em i img li ol p pre table td tfoot thead tr span strong ul font), attributes: %w(src href style color)).html_safe
  end

  def wrap_and_quote(content)
    content = html_to_text(content)
    content = word_wrap(content, line_width: 72)
    content.gsub(/^/, "> ")
  end

end
