require './plugins/post_filters'

module Jekyll
  class TocGenerator < PostFilter
    def pre_render(post)
      head, sep, tail = post.content.partition('{{TOC}}')
      return unless sep == '{{TOC}}'
      toc = tail.scan(/^##+ .+$/)
                .map { |t| t.gsub(/#+/) { ('  ' * ($~[0].size-2)) + '*' } }
                .map { |t| t.gsub(/\* (.+)/) { "* [#{$~[1]}](##{$~[1].to_url})" } }
                .join("\n")
      post.content = [head, toc, tail].join("\n")
    end

    def post_render(post)
      post.content = post.content.gsub(/<(h\d)>(.+)<\/\1>/) do
        "<#{$~[1]} id=\"#{$~[2].to_url}\">#{$~[2]}</#{$~[1]}>"
      end
    end
  end
end
