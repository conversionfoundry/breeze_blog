if defined?(Defender)
  module Breeze
    module Blog
      module Spam
        class DefensioStrategy < Strategy
          field :api_key
          
          class InvalidKey < StandardError; end
          
          validates_each :api_key do |record, attr, value|
            begin
              open("http://api.defensio.com/2.0/users/#{value}.yaml") do |f|
                y = YAML::load(f)["defensio-result"]
                raise InvalidKey unless y["status"] == "success"
              end
            rescue OpenURI::HTTPError => e
              record.errors.add attr, "is not a valid API key"
            end
          end
      
          def submit(comment)
            Defender.api_key = api_key
            document = document_from(comment)
            if document.save
              if document.allow?
                comment.publish! unless comment.blog.comment_moderation?
                Breeze.queue comment, :deliver_notification!
              else
                comment.spam!
              end
              comment.update_attributes :defensio_signature => document.signature
            end
          end
      
          def document_from(comment)
            if comment.attributes[:defensio_signature].present?
              Defender::Document.find(comment.defensio_signature)
            else
              returning Defender::Document.new do |document|
                document.data[:content]          = comment.body(:source)
                document.data[:type]             = "comment"
                document.data[:platform]         = "defender"
                document.data[:author_name]      = comment.name
                document.data[:author_email]     = comment.email
                document.data[:author_url]       = comment.website
                document.data[:author_logged_in] = comment.authenticated?
                document.data[:author_trusted]   = comment.authenticated?
              end
            end
          end
        end
      end
    end
  end
end