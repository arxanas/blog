module Jekyll
  module SortPostsFilter
    def sort_posts(input)
      input.sort_by { |post| [post.date, post.data.dig('series', 'index') || 0] }
    end
  end
end

Liquid::Template.register_filter(Jekyll::SortPostsFilter)
