# -*- coding: utf-8 -*-
module HtmlParseable
  require 'nokogiri'
  require 'nokogiri-styles'
  require 'sanitize'

  extend ActiveSupport::Concern

  included do
  end

  module ClassMethods
  end

  def fix_parsing_page
    [
      [/allowfullscreen/, "allowfullscreen=\"\""],
      ["\r", ""],
      [/<math>(.*?)<\/math>/m, "<math></math>"]
    ]
  end

  def parse_page(attr)
    html = send(attr)
    fix_parsing_page.inject(html){|val, repl| val = val.to_s.gsub(repl.first, repl.last)}
  end

  def validation_hash
    transformer = lambda do |env|
      return unless env[:node_name] == 'img'
      node = env[:node]
      width = node.styles['width']
      return unless width
      node.unlink unless width =~ /^[0-9]+%$/
    end

    {
      :allow_doctype => true,

      :elements => %w[a b body br div h1 h2 h3 h4 h5 hr html i iframe img li math ol p span sub sup table td th tr u ul ],

      :attributes => {
        :all     => %w[class style],
        'a'      => %w[href],
        'iframe' => %w[src width height scrolling name allowtransparency frameborder allowfullscreen mozallowfullscreen webkitallowfullscreen oallowfullscreen msallowfullscreen],
        'img'    => %w[src]
      },

      :protocols => {
        'a'      => {'href' => ['https', :relative]},
        'iframe' => {'href' => ['https']},
        'img'    => {'src'  => ['https']}
      },

      :css => {
        :properties => %w[width margin-left]
      },

      :transformers => transformer
    }
  end

  def parse_errors(attr)
    page = parse_page(attr)
    parsed = Sanitize.fragment(page, validation_hash)
    lines1 = page.lines
    lines2 = parsed.lines

    errors = []
    [lines1.length, lines2.length].max.times do |nr|
      line1 = lines1[nr].to_s.strip
      line2 = lines2[nr].to_s.strip
      errors << [line1, line2] unless line1 == line2
    end
    errors
  end

  #######################################################################################

  def html_images(attr)
    page = parse_page(attr)
    parsed_page = Nokogiri::HTML(page)
    parsed_page.css('img')
  end

  def image_errors(attr, reference = "")
    asset_host = "https://assets.studyflow.nl"
    errors = []
    html_images(attr).each do |el|
      error = nil
      src = el["src"]
      if src
        if src =~ /^#{ asset_host }\//
          image = Image.find_by_url(src)
          if image
            error = "`#{ src }` is not checked for dimensions" unless image.checked?
          else
            error = "`#{ src }` is not found in our assets database"
          end
        else
          error = "`#{ src }` is not a valid image source"
        end
      else
        error = "no 'src' value given for image"
      end
      if error
        error << "<br><small>(in #{ reference })</small>" if reference != ""
        errors << error.html_safe
      end
    end
    errors
  end

end
