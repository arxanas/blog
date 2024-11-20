require_relative 'hacky_render'

module Jekyll
  module Tags
    class NoteBlock < Liquid::Block
      include Jekyll::Filters
      include HackyRender

      def initialize(tag_name, text, tokens)
        super
        case text.strip
        in ("note-info" | "note-warning" | "note-error") => clazz
          @class = clazz
        in other
          raise Exception.new("invalid noteblock type #{other.inspect} (must match existing CSS class)")
        end
      end

      def render(context)
        contents = hacky_render(context, super)

        html = <<-HTML
        <div class="note-block #{@class}">
          #{contents}
        </div>
        HTML
        html.strip
      end
    end
  end
end

Liquid::Template.register_tag('noteblock', Jekyll::Tags::NoteBlock)
