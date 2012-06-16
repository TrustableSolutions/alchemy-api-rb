require 'json/ext'
require 'faraday'

module AlchemyAPI
  class Base
    attr_accessor :options, :response

    def search(opts)
      @options = opts

      @response = connection.post(path, construct_body)

      parsed_response
    end

    def parsed_response
      case Config.output_mode
      when :json
        JSON.parse(@response.body)
      else
        # [Crack::XML.parse(@response.body)["results"]["keywords"]["keyword"]].flatten
      end
    end

    def merged_options(opts)
      opts.merge(Config.default_options)
    end

    private

    def connection
      @connection ||= Faraday.new(url: BASE_URL)
    end

    def mode
      raise MissingOptionsError.new unless options && options.keys

      [:text, :url, :html].each do |type|
        return type if options.keys.include?(type)
      end

      raise MissionOptionsError.new
    end

    def method_prefix
      case mode
      when :text then "Text"
      when :url then "URL"
      when :html then "HTML"
      end
    end

    def path
      "#{mode}/#{web_method}"
    end

    def construct_body
      body = { apikey: Config.apikey }.merge!(merged_options(options))

      body.map { |e| e.join('=') }.join('&')
    end
  end
end

