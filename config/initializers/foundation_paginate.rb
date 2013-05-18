# Based on https://gist.github.com/1182136 and https://gist.github.com/1586384
# Make the will_paginate generate markup for Zurb Foundation
# Put this in config/initializers/foundation_paginate.rb
module WillPaginate
  module ViewHelpers
    class LinkRenderer < LinkRendererBase
      protected

      def html_container(html)
        tag(:ul, html, container_attributes)
      end

      def page_number(page)
        tag :li, link(page, page, :rel => rel_value(page)), :class => ('current' if page == current_page)
      end

      def gap
        tag :li, link(super, ''), :class => 'unavailable'
      end

      def previous_or_next_page(page, text, classname)
        tag :li, link(text, page || ''), :class => [classname[0..3], classname, ('unavailable' unless page)].join(' ')
      end
    end
  end
end
