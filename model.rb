class ShortenedUrl
  include DataMapper::Resource

  property :id, Serial
  property :url, Text
#   property :label, Text
end

