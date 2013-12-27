module ApplicationHelper

  def handle(user)
    if policy(user).inspect?
      if user.name && !user.name.empty?
        return "#{user.username} \"#{user.name}\""
      else
        return "#{user.username} <#{user.email}>"
      end
    else
      return "#{user.username}"
    end
  end

  def predisplay(string, type: :code, language: nil, **options)
    truncated_string = Code.limitstring(string, **options.extract!(:linelimit, :charlimit))
    continuation = (truncated_string.length < string.length) ? content_tag(:div, "...", :class => "continuation") : ""

    options.merge!(lexer: :text) if %i[samp kbd].include?(type)
    options.merge!(lexer: language) unless language.nil?
    contents = Pygments.highlight(truncated_string, :options => options.merge(encoding: 'utf-8', linespans: 'line', cssclass: :highlight)).html_safe
    contents += continuation
    #contents = content_tag(type, contents) if %i[samp kbd code].include?(type) # <code><pre></pre></code> is invalid html
    contents
  end

  def y(string)
    return string if !%w{yes no}.include?(string) && string =~ (/\A[[:alpha:]\.][[:alnum:]\.]*\z/) # safe for unquoted use
    string.to_json # JSON is a subset of YAML
  end

  def progress_bar(percent, link = nil, options = {})
    options.reverse_merge!(size: :standard)
    options[:width] = options[:size]==:compact ? '30px' : '100px' unless options.has_key?(:width)
    unless percent.nil?
      percent = percent.to_i
      text = percent.to_s
      text += '%' unless options[:size] == :compact
    else
      text = '-'
    end
    if link != nil
      text = link_to(text,link,{:class => "progress_link", :style => "display: block; width: 100%;"})
    end
    if percent.nil?
      colour = "rgb(192,192,192)"
      percent = 0;
    elsif percent <= 50 # make a nice spectrum of colours
      colour = "rgb(255,#{(percent*255/50).to_i},0)"
    else
      colour = "rgb(#{255-((percent-50)*255/50).to_i},#{255-((percent-50)*60/50).to_i},0)"
    end
    raw "<div style=\"display: inline-block; vertical-align: middle; position: relative; height: 18px; width: #{options[:width]}; border: 1px #{colour} solid;\"><div style=\"height: 100%; width: #{percent}%; background-color: #{colour}\"></div><div style=\"position: absolute; top: 0; left: 0; width: 100%; height: 100%; text-align: center; font-size: small; text-shadow: 1px 1px #FFFFFF;\">#{text}</div></div>"
  end

  def in_su?
    session[:su] && !session[:su].empty?
  end

  def icon name
    content_tag :i, "", :class => "icon-#{name}"
  end

  def toolbox_push text, link, options = {}
    if text.class == Symbol
      newopts = toolbox_options text
      text = newopts[:text] || text.to_s.capitalize
      options.reverse_merge! newopts.except(:text)
    end
    text = icon(options[:icon]) + text if options.has_key? :icon
    link_options = options.except(:icon, :color)
    content_for :toolbox do
      content_tag :li, :class => options[:color] do
        link_to link, link_options do
          text
        end
      end
    end
  end

  def toolbox_options symbol
    map = {
      :back => { :icon => :back, :color => :blue },
      :delete => { :icon => :trash, :color => :red, :method => :delete, :data => { :confirm => "Are you sure?" } },
      :edit => { :icon => :edit, :color => :blue },
      :new => { :icon => :new, :color => :blue },
      :apply => { :icon => :mail, :color => :blue, :method => :put },
      :join => { :icon => :login, :color => :green, :method => :put },
      :leave => { :icon => :logout, :color => :red, :method => :put }
    }
    map[symbol]
  end

  def qless_job_path(job_or_jid)
    jid = job_or_jid.respond_to?(:jid) ? job_or_jid.jid : job_or_jid
    "#{qless_server_path}/jobs/#{jid}"
  end

  def qless_tag_path(tag)
    "#{qless_server_path}/tag?tag=#{u(tag)}"
  end
end

