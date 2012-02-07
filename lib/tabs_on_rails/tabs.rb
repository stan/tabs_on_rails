#--
# Tabs on Rails
#
# A simple Ruby on Rails plugin for creating and managing Tabs.
#
# Copyright (c) 2009-2012 Simone Carletti <weppos@weppos.net>
#++


require 'tabs_on_rails/tabs/builder'
require 'tabs_on_rails/tabs/tabs_builder'
require 'tabs_on_rails/tabs/navbar_tabs_builder'

module TabsOnRails

  class Tabs

    def initialize(context, options = {})
      @context = context
      @builder = (options.delete(:builder) || NavbarTabsBuilder).new(@context, options)
      @options = options
    end

    %w(open_tabs close_tabs).each do |name|
      define_method(name) do |*args|                      # def open_tabs(*args)
        method = @builder.method(name)                    #   method = @builder.method(:open_tabs)
        if method.arity.zero?                             #   if method.arity.zero?
          method.call                                     #     method.call
        else                                              #   else
          method.call(*args)                              #     method.call(*args)
        end                                               #   end
      end                                                 # end
    end

    def method_missing(*args, &block)
      case args.first
      when :divider
        @builder.divider(*args, &block)
      when :nolink
        @builder.nolink(*args, &block)
      else
        @builder.tab_for(*args, &block)
      end
    end

    # Renders the tab stack using the current builder.
    #
    # Returns the String HTML content.
    def render(&block)
      raise LocalJumpError, "no block given" unless block_given?

      options = @options.dup
      dropdown = options.delete(:dropdown)
      open_tabs_options  = options.delete(:open_tabs)  || {}
      open_tabs_options.merge! :class => "dropdown-menu" if dropdown
      close_tabs_options = options.delete(:close_tabs) || {}

      "".tap do |html|
        html << @context.tag(:li, :class => "dropdown") if dropdown
        html << @context.link_to(dropdown[:name], '#', :class => "dropdown-toggle") if dropdown
        html << open_tabs(open_tabs_options).to_s
        html << @context.capture(self, &block)
        html << close_tabs(close_tabs_options).to_s
        html << "</li>" if dropdown
      end.html_safe
    end

  end

end
