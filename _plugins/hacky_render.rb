module HackyRender
  def hacky_render(context, markdown)
    site = context.registers[:site]
    converter = site.find_converter_instance(Jekyll::Converters::Markdown)
    converter.convert(markdown.strip)
  end
end
