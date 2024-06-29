module Jekyll
    module AnchorFilter
      def blog_anchor(input)
        anchor_id = input.gsub(' ', '-').downcase
        "<h1><a href='##{anchor_id}' id='#{anchor_id}'>⦾ #{input}</a></h1>"
      end
    end
  end

Liquid::Template.register_filter(Jekyll::AnchorFilter)