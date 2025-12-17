require 'uri'
require 'net/http'

class TmdbService

    def initialize
        @api_key = ENV["TMDB_API_KEY"]
        raise "API key not found" if @api_key.blank?
    end

    #* Reference: https://developer.themoviedb.org/reference/discover-movie
    def search_by_date_range(start_date, end_date)
        url = URI(
            "https://api.themoviedb.org/3/discover/movie?"\
            "api_key=#{@api_key}"\
            "&primary_release_date.gte=#{start_date}"\
            "&primary_release_date.lte=#{end_date}"\
            "&include_adult=false"\
            "&include_video=false"\
            "&language=en-US"\
            "&page=1"\
            "&sort_by=popularity.desc"
        ) #* Getting only the first page for simplicity

        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE #* I'm bypassing OpenSSL's certificate verification for simplicity 

        request = Net::HTTP::Get.new(url)
        request["accept"] = 'application/json'

        response = http.request(request)
        JSON.parse(response.read_body.force_encoding('UTF-8'))
    end
end