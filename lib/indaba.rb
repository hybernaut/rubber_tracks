require "rubygems"
require "json"
require "net/http"
require "uri"
require 'active_support'
require 'active_support/core_ext' # for Object.to_query
require 'active_support/hash_with_indifferent_access'
require 'ostruct'

require 'pry'

# indaba API for Converse Rubber Tracks library
class SampleLibrary

  class Package

    def initialize(package_id)
      @id = package_id
      request
    end

    def request
      @raw ||= SampleLibrary::request(package_id: @id)
    end

    # returns a filtered list of samples in the package
    # samples(type: 'loop')
    def samples(filter={})
      @samples ||= request.map{|jtxt| Sample.new(ActiveSupport::HashWithIndifferentAccess.new(jtxt))} # .to_hash_by('_id')

      # apply all filters
      result = @samples
      filter.each do |k,v|
        if ARRAY_KEYS.include?(k)
          result = result.find_all{|s| s.send(k).map(&:upcase).include?(v.upcase)}
        else
          result = result.find_all{|s| s.send(k) == v}
        end
      end
      result
    end

    ARRAY_KEYS=[:instruments]

  end

  class Sample < OpenStruct

    def initialize(*args)
      super
    end

  end

  ENDPOINT_HOST = 'hackathon.indabamusic.com'

  def self.request(params={})

    uri = URI::HTTP.build(host: ENDPOINT_HOST, path: '/samples', query: params.to_query)

    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)

    response = http.request(request)

    if response.code == "200"
      return JSON.parse(response.body)
    end
  end

end

class Array
  def to_hash_by(key_method=:id, &block)

    each_with_object(Hash.new) do |item,hash|

      if item.respond_to?(key_method)
        key = item.send(key_method)
      elsif item.kind_of?(Hash)
        key = item[key_method]
      end

      if item && block_given?
        item = block.call(item)
      end

      if key && item
        hash[ key ] = item
      end
    end

  end
end

pkg = SampleLibrary::Package.new('54cd09b0e4b05f58f99c4675')

binding.pry

__END__

{
  "_id"=>"54cbca61e4b01a682b799d0d",
 "song_name"=>"Free",
 "instrument_names"=>[],
 "deleted_at"=>nil,
 "release_date"=>"2015-01-30",
 "rand"=>0.09030751898001144,
 "influences"=>[],
 "name"=>"Backing Loop 1",
 "genres"=>["Dance", "Electronic"],
 "s3_status"=>"",
 "publishers"=>[],
 "songwriters"=>[],
 "equipment"=>[],
 "moods"=>[],
 "musical_key"=>"G Minor",
 "type"=>"loop",
 "duration"=>3902,
 "artist"=>"Body Language",
 "performers"=>["Matt Young", "Angelica Bess", "Ian Chang", "Grant Wheeler"],
 "note"=>nil,
 "updated_at"=>"2015-02-05T18:16:48.917Z",
 "instruments"=>["Percussion", "Vocals", "Synths"],
 "agreements"=>[],
 "recording_engineers"=>["Aaron Bastinelli"],
 "packages"=>["54cd09b0e4b05f58f99c4675", "54cd09b0e4b05f58f99c4675"],
 "producers"=>[],
 "album"=>nil,
 "version"=>1.1,
 "tempo"=>123,
 "s3_key"=>"f6428d93-09a5-4505-b808-14fee3dc69ac/f6428d93-09a5-4505-b808-14fee3dc69ac.wav",
 "mixing_engineers"=>["Garrett Frierson"],
 "created_at"=>"2015-01-30T18:16:01.383Z"
}
