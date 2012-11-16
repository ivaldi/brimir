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
end
