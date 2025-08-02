# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end


default_keywords = [
  'bom', 'ótimo', 'excelente', 'maravilhoso', 'perfeito', 'odio',
  'incrível', 'fantástico', 'impressionante', 'lindo', 'amazing',
  'good', 'great', 'excellent', 'wonderful', 'perfect', 'Facilis',
  'easy', 'simple', 'quick', 'fast', 'efficient', 'effective',
  'awesome', 'beautiful', 'outstanding', 'incredible', 'fantastic',
  'amazing', 'good', 'great', 'excellent', 'wonderful', 'perfect',
  'easy', 'simple', 'quick', 'fast', 'exercicies', 'effective',
  'incredible', 'lorem', 'awesome', 'beautiful', 'outstanding',
  # Adding some synonyms and variations
  'bom', 'ótimo', 'excelente', 'maravilhoso', 'perfeito',
  'incredible', 'fantastic', 'awesome', 'beautiful', 'outstanding'
]

puts "Creating default keywords..."
default_keywords.each do |word|
  Keyword.find_or_create_by(word: word.downcase) do |keyword|
    keyword.active = true
  end
end
