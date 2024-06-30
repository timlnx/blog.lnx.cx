module Jekyll
    module AnchorFilter
      def normalize(input)
        # all lowercase, spaces into hyphens, any remaining non-alphanumeric or
        # hyphen characters are dropped
        #
        # does not promise to generate a unique DOM ID. That's up to you.
        input.downcase.gsub(' ', '-').gsub(/[^0-9a-zA-Z-]/, '')
      end

      def blog_anchor(input)
        # Insert a self-linked header. The link target provides a permalink type
        # anchor. The header is normalized into a valid DOM ID. See
        # self.normalize()
        #
        # Usage: Create an <h1> header that can be used for permalinks
        #     {{ "Section you might want to share a direct link to?" | blog_anchor "}}
        anchor_id = self.normalize(input)
        "<h1><a href='##{anchor_id}' id='#{anchor_id}'>⦾ #{input}</a></h1>"
      end

      def blog_anchor_link(input, display_text=nil)
        # Usage 1: Link using the exact header name:
        #     {{ "Header like you give to blog_anchor filter" | blog_anchor_link }}
        #
        # Usage 2: Link with custom text:
        #     {{ "Header like you give to blog_anchor filter" | blog_anchor_link: "Custom link text" }}
        link_text = display_text ? display_text : input
        "<a href='##{self.normalize(input)}'>#{link_text}</a>"
      end
    end
  end

Liquid::Template.register_filter(Jekyll::AnchorFilter)