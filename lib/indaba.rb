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

    attr_accessor :id

    def initialize(package_id)
      @id = package_id
      request
    end

    def request
      puts "Downloading metadata for package #{@id}..." unless @raw
      @raw ||= SampleLibrary::request(package_id: @id)
    end

    def valid?
      @raw.present?
    end

    # returns a filtered list of samples in the package
    # samples(type: 'loop')
    def samples(filter={})
      @samples ||= request.map{|jtxt| Sample.new(self, ActiveSupport::HashWithIndifferentAccess.new(jtxt))}

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

    def initialize(package, hash={})
      @package = package
      super hash
    end

    BASE_PATH = 'packages'

    def path(format='mp3')
      File.join(BASE_PATH, @package.id, [name, format].join('.'))
    end

    def wav_key
      s3_key
    end

    def mp3_key
      s3_key.gsub(/(wav)$/, 'mp3')
    end

    DOWNLOAD_HOST='d34x6xks9kc6p2.cloudfront.net'
    def download(force=false)
      FileUtils.mkdir_p(File.join(BASE_PATH,@package.id))

      if File.exist?(path)
        if force
          puts "Re-downloading #{path}"
        else
          puts "File #{path} already downloaded"
          return
        end
      else
        puts "Downloading #{path}"
      end

      # path must be absolute path '/foo'
      uri = URI::HTTP.build(scheme: 'https', host: DOWNLOAD_HOST, path: '/' + mp3_key )

      Net::HTTP.start(uri.host, uri.port) do |http|
        request = Net::HTTP::Get.new uri

        http.request request do |response|
          open path , 'w' do |io|
            response.read_body do |chunk|
              io.write chunk
            end
          end
        end
      end
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
    else
      puts "Request #{uri.to_s} failed with error #{response.code}"
      return nil
    end
  end

end

pkg_id = ENV['PACKAGE'] || '54cd09b0e4b05f58f99c4675'

cmd = ARGV.shift

pkg = SampleLibrary::Package.new(pkg_id)

if pkg.valid?

  loops = pkg.samples(type: 'loop', instruments: 'drums')
  shots = pkg.samples(type: 'one_shot', instruments: 'drums')

  case cmd
  when 'summary'
    puts "summary of package #{pkg_id}"
    if loops.any?
      puts "#{loops.length} drum loops"
    end
    if shots.any?
      puts "#{shots.length} drum one-shots"
    end
  when 'download'
    if ARGV.any?
      while sample_type = ARGV.shift do
        case sample_type
        when 'loop', 'loops'
          puts "Downloading #{loops.length} samples"
          loops.each &:download
        when 'shots', 'one-shots'
          puts "Downloading #{shots.length} samples"
          shots.each &:download
        end
      end
    else
      puts "specify which type of samples you want to download (one-shots, loops)"
    end
  else
    puts "unrecognized command #{cmd}"
  end
else
  puts "Unable to retrieve package #{pkg_id}" and exit
end

__END__

a sample Sample
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
