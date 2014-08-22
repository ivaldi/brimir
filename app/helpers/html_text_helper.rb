module HtmlTextHelper
  
  def html_to_text(content)
    sanitize(content.gsub(/(<br( )?\/>|<\/p>)/, "\n"), tags: [])
  end

  def text_to_html(content)
    content.gsub("\n", '<br />')
  end

  def sanitize_html(content)
    sanitize(content, tags: %w(a b br code div em i img li ol p pre table td tfoot thead tr span strong ul), attributes: %w(src href)).html_safe
  end

end
