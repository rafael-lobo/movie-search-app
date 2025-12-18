class MoviesController < ApplicationController
    def search
        start_date = Date.parse(params[:start_date]) rescue nil
        end_date = Date.parse(params[:end_date]) rescue nil
        
        service = TmdbService.new
        movies = service.search_by_date_range(start_date, end_date)
        movies 
    end
end
