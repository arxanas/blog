require_relative 'hacky_render'

# Example taken from https://gist.github.com/brandonmwest/6262934
module Jekyll
  module Tags
    class TikzBlock < Liquid::Block
      include Jekyll::Filters
      include HackyRender

      def initialize(tag_name, text, tokens)
        super
        @title = text.strip
      end

      def render(context)
        contents = hacky_render(context, super)

        # http://stackoverflow.com/a/4308399/344643
        slug = @title.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
        slug = xml_escape(slug)
        slug = slug[0...25]

        title = xml_escape(@title)
        if @title.empty?
          raise Exception.new("no title for aside block")
        end

        html = <<-HTML
        <details id="#{slug}">
          <summary>#{title}</summary>
          <div>#{contents}</div>
        </details>
        HTML
        html.strip
      end
    end
  end
end

Liquid::Template.register_tag('tikz', Jekyll::Tags::TikzBlock)
