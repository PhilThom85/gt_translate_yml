require 'rubygems'
require 'mechanize'

module Google
  class Translate < Mechanize

    LANG = { :bg => { :in => 'iso-8859-5', :out => 'utf-8', :lang => 'Bulgarian' },
             :ja => { :in => 'shift-jis',  :out => 'utf-8', :lang => 'Japanese' },
             :ru => { :in => 'koi8-r',     :out => 'utf-8', :lang => 'Russian' },
             :ko => { :in => 'euc-kr',     :out => 'utf-8', :lang => 'Korean' },
             :ar => { :in => 'iso-8859-6', :out => 'utf-8', :lang => 'Arabic' },
             :hr => { :in => 'iso-8859-2', :out => 'utf-8', :lang => 'Croatian' },
             :cs => { :in => 'iso-8859-2', :out => 'utf-8', :lang => 'Czech' },
             :pl => { :in => 'iso-8859-2', :out => 'utf-8', :lang => 'Polish' },
             :da => { :in => 'iso-8859-1', :out => 'utf-8', :lang => 'Danish' },
             :nl => { :in => 'iso-8859-1', :out => 'utf-8', :lang => 'Dutch' },
             :en => { :in => 'iso-8859-1', :out => 'utf-8', :lang => 'English' },
             :fi => { :in => 'iso-8859-1', :out => 'utf-8', :lang => 'Finnish' },
             :fr => { :in => 'iso-8859-1', :out => 'utf-8', :lang => 'French' },
             :de => { :in => 'iso-8859-1', :out => 'utf-8', :lang => 'German' },
             :it => { :in => 'iso-8859-1', :out => 'utf-8', :lang => 'Italian' },
             :no => { :in => 'iso-8859-1', :out => 'utf-8', :lang => 'Norwegian' },
             :es => { :in => 'iso-8859-1', :out => 'utf-8', :lang => 'Spanish' },
             :pt => { :in => 'iso-8859-1', :out => 'utf-8', :lang => 'Portuguese' },
             :el => { :in => 'iso-8859-7', :out => 'utf-8', :lang => 'Greek' },
             :hi => { :in => 'iso-8859-13', :out => 'utf-8', :lang => 'Hindi' },
             :ro => { :in => 'iso-8859-2', :out => 'utf-8', :lang => 'Romanian' },
             :"zh-CN" => { :in => 'gb18030', :out => 'utf-8', :lang => 'Chinese Simplified' },
             :"zh-TW" => { :in => 'big5', :out => 'utf-8', :lang => 'Chinese Traditional' } }

    URL = "http://translate.google.com/translate_t"

    # Takes source and destination languages, and text.
    # Returns utf-8 encoded string.
    def translate(params={})
      from = params[:from]
      to   = params[:to]
      text = params[:text]

      if !text or text.empty?
        raise ArgumentError, "No text given", caller
      end

      if !LANG.key?(to.to_sym)
        raise ArgumentError, "Invalid 'to' language given", caller
      end

      if !LANG.key?(from.to_sym)
        raise ArgumentError, "Invalid 'from' language given", caller
      end

      result = self.post(URL,
                "sl"   => from, 
                "tl"   => to, 
                "text" => text).search("#result_box").inner_text

      result.encode!(LANG[to.to_sym][:out], LANG[to.to_sym][:in])
      return case self.user_agent
        when /mechanize/i
         result.encode!(LANG[to.to_sym][:out], LANG[to.to_sym][:in])
        when /^[^www]/i
         result
      end
    end

    def new(*args)
      super 
    end

    # Returns the languages' names, their abbreviations and Google encoding.
    def self.languages
      LANG.sort_by{ |e| e[1][:lang] }
    end
  end
end
