require_relative 'asset_path_tag'
require_relative 'hacky_render'
require 'shellwords'

module Jekyll
  class ImageTag < Jekyll::AssetPathTag
    include Jekyll::Filters
    include HackyRender

    def initialize(tag_name, markup, tokens)
      markup, @alt_text, *caption_text = Shellwords.shellsplit(markup)
      @caption_text = caption_text[0] || @alt_text

      super tag_name, markup, tokens
    end

    def render(context)
      asset_url = super

      title_text = @alt_text.gsub(/[ \t\n]+/, ' ')
      title_text = xml_escape(title_text)

      html = <<-HTML
      <figure class="figure">
        <a href="#{asset_url}"><img
          class="center-image"
          src="#{asset_url}"
          alt="#{title_text}"
          title="#{title_text}"
        ></a>
        <figcaption class="caption">#{hacky_render(context, @caption_text)}</figcaption>
      </figure>
      HTML
      html.strip
    end
  end
end

Liquid::Template.register_tag('image', Jekyll::ImageTag)
