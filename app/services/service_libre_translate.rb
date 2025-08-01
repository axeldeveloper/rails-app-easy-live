class ServiceLibreTranslate
    include HTTParty
    # base_uri 'https://libretranslate.de'
    base_uri "http://localhost:5000"

    def self.translate(text, source = "en", target = "pt")
      Rails.logger.info "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
      Rails.logger.info "Executing translate "
      Rails.logger.info text
      res = post("/translate",
        headers: { "Content-Type" => "application/json" },
        body: {
          q: text,
          source: source,
          target: target,
          format: "text",
          api_key: ENV["LIBRE_TRANSLATE_API_KEY"]
        }.to_json)
      res["translatedText"] rescue text
    end
end
