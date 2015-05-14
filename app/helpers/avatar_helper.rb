# # Generating User Avatars
#
# This feature adds optional user avatars to email addresses
# displayed in the application.
#
# The avatars are fetched using the gravatar service, which can
# be found at http://gravatar.com.
# 
# The gem *gravatar_image_tag* is used:
# https://github.com/mdeering/gravatar_image_tag
# 
# ## Global Settings
# 
# Global settings can be configured in the `config/settings.yml` file.
# 
#   * `display_user_avatars`: `true`, `false`
#       Whether to use the avatar feature.
#       Default: `false`
#
#   * `default_user_avatar`: url or gravatar default setting
#       The avatar that is shown when no avatar can be determined
#       for an email address.
#       Default: `'identicon'`
# 
#       Possible settings:
#         - any image url,
#           for example, this github icon url:
#           "https://assets.github.com/images/gravatars/gravatar-140.png"
#         - `"mm"`: (mystery-man)
#           a simple, cartoon-style silhouetted outline of a person
#         - `"identicon"`:
#           a geometric pattern based on an email hash
#         - `"monsterid"`:
#           a generated 'monster' with different colors, faces, etc
#         - `"wavatar"`:
#           generated faces with differing features and backgrounds
#         - `"retro"`:
#           awesome generated, 8-bit arcade-style pixelated faces
#         - `"blank"`:
#           a transparent PNG image
# 
#         See also: https://gravatar.com/site/implement/images/
# 
# ## Usage
# 
# In the views, you can insert the avatar image tag of a `user` inline:
# 
#     <%= user_avatar(user) %>
# 
# In order to adjust an avatar left of some content, you may use these
# pre-defined css classes:
# 
#    <div class="avatar-left"><%= user_avatar(user) %></div>
#    <div class="avatar-matter">
#      Other Content
#      For example, an email of the user.
#    </div>
#
module AvatarHelper
  
  # Generates a user avatar image tag if `display_user_avatars`
  # is set to true in `conifg/settings.yml`.
  #
  # Options:
  #   - size
  #   - (see gravatar_default_options)
  # 
  def user_avatar(user, options = {})
    @user_avatar ||= {}
    @user_avatar[[user.id, options]] ||= user_gravatar(user, options) if AppSettings.display_user_avatars
  end
  
  # Display the user avatar if `AppSetting.display_user_avatars` is `true`.
  # Otherwise, display `<i class="fa fa-user"></i>`.
  #
  def user_avatar_or_fa_user_icon(user)
    user_avatar(user) || content_tag(:i, class: 'fa fa-user')
  end
  
  private

  def user_gravatar(user, options = {})
    options[:gravatar] ||= {}
    options[:gravatar][:size] ||= options[:size] if options[:size]
    gravatar_image_tag(user.email, gravatar_default_options.deep_merge(options))
  end
  
  def gravatar_default_options
    {
      :gravatar => {
        :size => 24,
        :secure => true,
        :default => default_avatar_url
      },
      :class => 'user-avatar'
    }
  end
  
  # This sets the default gravatar image.
  # 
  # Possible values are:
  #   - any image url,
  #     for example, this github icon url:
  #     "https://assets.github.com/images/gravatars/gravatar-140.png"
  #   - "mm":
  #     (mystery-man) a simple, cartoon-style silhouetted outline of a person
  #   - "identicon":
  #     a geometric pattern based on an email hash
  #   - "monsterid":
  #     a generated 'monster' with different colors, faces, etc
  #   - "wavatar":
  #     generated faces with differing features and backgrounds
  #   - "retro":
  #     awesome generated, 8-bit arcade-style pixelated faces
  #   - "blank":
  #     a transparent PNG image
  #
  # See also: https://gravatar.com/site/implement/images/
  # 
  def default_avatar_url
    AppSettings.default_user_avatar || 'identicon'
  end
  
end