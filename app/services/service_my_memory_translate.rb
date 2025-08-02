class ServiceMyMemoryTranslate
  include HTTParty
  base_uri "https://api.mymemory.translated.net"

  def self.translate(text, from = "en", to = "pt")
    response = get("/get", query: {
      q: text,
      langpair: "#{from}|#{to}"
    })

    if response.success? && response["responseStatus"] == 200
      response.dig("responseData", "translatedText")
    else
      Rails.logger.error "MyMemory translation failed: #{response}"
      text # Retorna o texto original se falhar
    end
  rescue => e
    Rails.logger.error "MyMemory error: #{e.message}"
    text
  end
end
