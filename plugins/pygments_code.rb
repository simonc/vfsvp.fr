require 'pygments'
require 'fileutils'
require 'digest/md5'

PYGMENTS_CACHE_DIR = File.expand_path('../../.pygments-cache', __FILE__)
FileUtils.mkdir_p(PYGMENTS_CACHE_DIR)

module HighlightCode
  def highlight(str, lang)
    lang = 'ruby' if lang == 'ru'
    lang = 'objc' if lang == 'm'
    lang = 'perl' if lang == 'pl'
    lang = 'yaml' if lang == 'yml'
    str = pygments(str, lang).match(/<pre>(.+)<\/pre>/m)[1].to_s.gsub(/ *$/, '') #strip out divs <div class="highlight">
    tableize_code(str, lang)
  end

  def pygments(code, lang)
    if defined?(PYGMENTS_CACHE_DIR)
      path = File.join(PYGMENTS_CACHE_DIR, "#{lang}-#{Digest::MD5.hexdigest(code)}.html")
      if File.exist?(path)
        highlighted_code = File.read(path)
      else
        begin
          highlighted_code = Pygments.highlight(code, :lexer => lang, :formatter => 'html', :options => {:encoding => 'utf-8', :startinline => true})
        rescue MentosError
          raise "Pygments can't parse unknown language: #{lang}."
        end
        File.open(path, 'w') {|f| f.print(highlighted_code) }
      end
    else
      highlighted_code = Pygments.highlight(code, :lexer => lang, :formatter => 'html', :options => {:encoding => 'utf-8', :startinline => true})
    end
    highlighted_code
  end

  def tableize_code (str, lang = '')
    code = str.lines.map { |line| "<span class='line'>#{line}</span>" }.join
    table = %Q{<div class="highlight"><pre><code class='#{lang}'>#{code}</code></pre></div>}
  end
end
