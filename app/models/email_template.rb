class EmailTemplate < ApplicationRecord

  enum kind: [:user_welcome, :ticket_received]

  scope :by_kind, -> (k) { where(kind: kinds[k]) }
  scope :active, -> { where.not(draft: true) }

  validates_presence_of :kind

  def self.create_default_templates(kinds, options={})
    # default templates are based on the I18n.locale
    kinds.each do |kind|
      create prefill_by(kind).merge(options)
    end
  end

  def is_active?
    !draft?
  end

  def all_others_to_draft(kind)
    self.class.where('id != ?', self.id)
      .by_kind(kind)
      .active.update_all(draft: true)
  end

  protected

  def self.prefill_by(kind)
    {
      name: default_name(kind),
      draft: false,
      kind: kind,
      message: default_message(kind)
    }
  end

  def self.default_name(kind)
    I18n.t "activerecord.attributes.email_template.kinds.#{kind}.template_name"
  end

  def self.default_message(kind)
    I18n.t "activerecord.attributes.email_template.kinds.#{kind}.message"
  end

end
