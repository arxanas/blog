require_relative 'hacky_render'

# Example taken from https://gist.github.com/brandonmwest/6262934
module Jekyll
  module Tags
    class AsideBlock < Liquid::Block
      include Jekyll::Filters
      include HackyRender

      def initialize(tag_name, text, tokens)
        super
        @title = text.strip
      end

      def render(context)
        contents = hacky_render(context, super)

        title = xml_escape(@title)
        html = <<-HTML
        <aside>
          <label>
            <div class="aside">
              <header class="aside-header">#{title}</header>
              <input
                  class="aside-checkbox"
                  type="checkbox"
              >
              <div class="aside-contents">#{contents}</div>
            </div>
          </label>
        </aside>
        HTML
        html.strip
      end
    end
  end
end

Liquid::Template.register_tag('aside', Jekyll::Tags::AsideBlock)
