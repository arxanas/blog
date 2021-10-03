module RelatedPosts
  class Generator < Jekyll::Generator
    def generate(site)
      related_post_groups = site.config['related_posts']
      for post in site.posts.docs
        applicable_groups = related_post_groups.select { |group| group.include?(post.data['permalink']) }
        related_post_permalinks = applicable_groups.flatten.uniq
        related_posts = site.posts.docs.select { |post| related_post_permalinks.include?(post.data['permalink']) }
        related_posts.sort_by! { |post| post.date }
        post.data['related_posts'] = related_posts unless related_posts.empty?
        print("Related posts for #{post.data['permalink']}: #{related_posts}\n")
      end
    end
  end
end
