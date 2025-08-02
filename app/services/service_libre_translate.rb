class ServiceLibreTranslate
    include HTTParty
    # base_uri 'https://libretranslate.de'
    base_uri "http://localhost:5000"

    def self.translate(text, source = "en", target = "pt")
      res = post("/translate",
        headers: { "Content-Type" => "application/json" },
        body: {
          q: text,
          source: source,
          target: target,
          format: "text",
          api_key: nil
          # api_key: ENV["LIBRE_TRANSLATE_API_KEY"]
        }.to_json)
      res["translatedText"] rescue text
    rescue StandardError => e
      Rails.logger.info "=" * 50
      Rails.logger.error "Error processing translate #{text}: #{e.message}"
      Rails.logger.info "=" * 50
    end
end
