module Jekyll
  module Tags
    class PermalinkTag < Liquid::Tag
      def initialize(tag_name, markup, tokens)
        super
        @post_permalink = "#{markup.strip}/"
      end

      def render(context)
        possible_posts = context['site']['posts'].select do |post|
          post.permalink == @post_permalink
        end

        if possible_posts.empty?
          abort "No posts with permalink '#{@post_permalink}'"
        elsif possible_posts.length > 1
          # You'd think Jekyll would detect conflicting permalinks, but it does
          # not.
          post_titles = possible_posts.map { |post| "'#{post.title}'" }.join(', ')
          abort "Multiple posts with permalink '#{@post_permalink}': #{post_titles}"
        end

        "#{context['site']['baseurl']}/#{@post_permalink}"
      end
    end
  end
end

Liquid::Template.register_tag('permalink', Jekyll::Tags::PermalinkTag)
