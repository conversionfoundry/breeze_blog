xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title       blog.rss_title || blog.title
    xml.description blog.rss_description || ""
    xml.link        blog.permalink(:include_domain)
    xml.generator   "Breeze"

    for post in posts
      xml.item do
        xml.title       post.title
        xml.description do
          xml.cdata!    post.body
        end
        xml.pubDate     post.published_at.to_s(:rfc822)
        xml.link        post.permalink(:include_domain)
        xml.author      post.author.email
        xml.comments    post.permalink(:include_domain) + "#comments"
      end
    end
  end
end