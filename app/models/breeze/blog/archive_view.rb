module Breeze
  module Blog
    class ArchiveView < IndexView
      attr_accessor :year, :month, :day
      
      def set_url_params(match)
        self.year, self.month, self.day = [ 3, 5, 7 ].map { |i| match[i] && match[i].sub(/^0/, "").to_i }
      end
      
      def start_time
        @start_time ||= if year
          Time.zone.local(*[ year, month, day ].compact)
        else
          Time.zone.now
        end
      end
      
      def end_time
        start_time + if day
          1.day
        elsif month
          1.month
        else
          1.year
        end
      end
      
      def start_date
        start_time.to_date
      end
      
      def end_date
        end_time.to_date - 1.day
      end
      
      def posts
        super.where(
          :published_at.gte => start_time.utc,
          :published_at.lt  => end_time.utc
        )
      end
    end
  end
end