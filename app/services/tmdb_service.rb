require 'uri'
require 'net/http'
require 'json'

class TmdbService
    class ApiError < StandardError; end

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

        begin
            response = http.request(request)
            raise ApiError, "API request failed: #{response.code} #{response.message}" unless response.is_a?(Net::HTTPSuccess)

            parsed_response = JSON.parse(response.body)
            parse_results(parsed_response["results"])
        rescue JSON::ParserError
            raise ApiError, 'Invalid response from TMDB API'
        end
    end

    private

    def parse_results(results)
    results.map do |movie|
        {
            :tmdb_id => movie["id"],
            :title => movie["original_title"],
            :overview => movie["overview"],
            :popularity => movie["popularity"],
            :poster_path => movie["poster_path"],
            :release_date => movie["release_date"],
        }
    end
    end
end
