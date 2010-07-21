module Breeze
  module Blog
    ARCHIVE_PART  = /(\d{4})(\/(\d{1,2})(\/(\d{1,2})(\/([^\/]+))?)?)?/.freeze unless defined?(ARCHIVE_PART)
    CATEGORY_PART = /category\/([^\/]+)/.freeze unless defined?(CATEGORY_PART)
    TAG_PART      = /tag\/([^\/]+)/.freeze unless defined?(TAG_PART)
    PERMALINK     = /(\/(#{ARCHIVE_PART}|#{CATEGORY_PART}|#{TAG_PART}))?(\.\w+)?$/.freeze unless defined?(PERMALINK)
  end
end