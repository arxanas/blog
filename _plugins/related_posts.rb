module RelatedPosts
  class Generator < Jekyll::Generator
    def generate(site)
      posts_by_permalink = {}
      for post in site.posts.docs
        # HACK: Don't index translated posts for now. Currently, there's a
        # duplicate permalink metadata issue for the `yandex-arc` article (even
        # though the "real" permalink for one is `pl/yandex-arc/`).
        is_translated = !post.data.dig('translations', 'en').nil?
        next if is_translated

        post_permalink = post.data['permalink']
        if posts_by_permalink.has_key?(post_permalink)
          raise Exception.new("duplicate post permalink: #{post_permalink.inspect}: #{post.methods.inspect}")
        end
        posts_by_permalink[post_permalink] = post
      end

      for post in site.posts.docs
        # HACK: O(n^2) behavior since we process the same series once per post.
        # But I was getting some bugs in incremental builds since it seems like
        # some state is preserved between calls, and I didn't want to figure out
        # how to invalidate it correctly, so I didn't try to avoid the duplicate
        # work here.
        next if post.data['series'].nil?
        series_posts = [post]

        curr_post = post
        loop do
          prev_post_permalink = curr_post.data['series'].fetch('prev', nil)
          break if prev_post_permalink.nil?
          prev_post = posts_by_permalink[prev_post_permalink]
          if prev_post.nil?
            raise KeyError.new("not found for post #{curr_post.data['permalink'].inspect}: prev_post_permalink #{prev_post_permalink.inspect}")
          end
          if prev_post.data['series']['next'] != curr_post.data['permalink']
            raise Exception.new("series prev/next mismatch: #{curr_post.data['permalink'].inspect}: #{curr_post.data['series']['next'].inspect} != #{prev_post.data['permalink'].inspect}")
          end
          curr_post = prev_post
          series_posts.unshift(curr_post)
        end

        curr_post = post
        loop do
          next_post_permalink = curr_post.data['series'].fetch('next', nil)
          break if next_post_permalink.nil?
          next_post = posts_by_permalink[next_post_permalink]
          if next_post.nil?
            raise KeyError.new("not found for post #{curr_post.data['permalink'].inspect}: next_post_permalink #{next_post_permalink.inspect}")
          end
          if next_post.data['series']['prev'] != curr_post.data['permalink']
            raise Exception.new("series prev/next mismatch: #{curr_post.data['permalink'].inspect}: #{curr_post.data['series']['prev'].inspect} != #{next_post.data['permalink'].inspect}")
          end
          curr_post = next_post
          series_posts.push(curr_post)
        end

        series_posts.each_with_index { |p, i| p.data['series']['index'] = i }
        post.data['series']['posts'] = series_posts
      end

      # NOTE: There's an unrelated `site.related_posts` variable in Jekyll: https://jekyllrb.com/docs/variables/
      # This one is manually curated in `_config.yml`.
      related_post_groups = site.config['related_posts']
      for post in site.posts.docs
        related_groups = related_post_groups.select { |group| group.include?(post.data['permalink']) }
        related_group_permalinks = related_groups.flatten
        if post.data['series'].nil?
          series_post_permalinks = []
        else
          series_post_permalinks = post.data['series']['posts'].map { |p| p.data['permalink'] }
        end
        related_post_permalinks = ([post.data['permalink']] + related_group_permalinks + series_post_permalinks).uniq
        related_posts = site.posts.docs.select { |post| related_post_permalinks.include?(post.data['permalink']) }
        post.data['related_posts'] = related_posts
      end
    end
  end
end
