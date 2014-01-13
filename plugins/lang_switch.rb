# Title: lang switch Jekyll
# Author: Simon Courtois (@happynoff)
# Description:
#   Adds a tag with the lang attribute set
#
# Syntax: {% lg en [tag_name] %}
#
# Examples:
#
# Input: {l-fr bonjour}
# Output: <span lang="fr">bonjour</span>

require './plugins/post_filters'

module Jekyll
  class LangSwitch < PostFilter
    def pre_render(post)
      post.content = post.content.gsub(/\{l-(?<lang>[^ ]+) (?<text>[^}]+)\}/) do
        %Q(<em lang="#{$~[:lang]}">#{$~[:text]}</em>)
      end
    end
  end
end
