require "rubygems"
require "json"
require "net/http"
require "uri"
require 'active_support'
require 'active_support/core_ext' # for Object.to_query

require 'pry'

# indaba API for Converse Rubber Tracks library
class SampleLibrary

  class Package

    def initialize(package_id)
      @id = package_id
    end

    def request
      SampleLibrary::request(package_id: @id)
    end

  end

  class Sample

    def initialize
    end

  end

  ENDPOINT_HOST = 'hackathon.indabamusic.com'

  def self.request(params={})

    uri = URI::HTTP.build(host: ENDPOINT_HOST, path: '/samples', query: params.to_query)

    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)

    response = http.request(request)

    if response.code == "200"
      return result = JSON.parse(response.body)
    end
  end

end

pkg = SampleLibrary::Package.new('54cd09b0e4b05f58f99c4675').request
puts pkg.to_s
