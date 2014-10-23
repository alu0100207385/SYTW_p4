class ShortenedUrl
  include DataMapper::Resource

  property :id, Serial
  property :usu, Text
  property :url, Text
  property :label, Text
end
