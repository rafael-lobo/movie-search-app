class MoviesController < ApplicationController
    before_action :validate_dates, only: [:search]

    def search
        fill_missing_date_ranges(@start_date, @end_date)
        
        movies = Movie.where(release_date: @start_date..@end_date).order(popularity: :desc).limit(20)

        render json: {
            movies: movies.as_json(methods: :poster_url),
            count: movies.size,
            total_available: Movie.count(:all)
        }
    end

    private

    def validate_dates
        @start_date = Date.parse(params[:start_date])
        @end_date = Date.parse(params[:end_date])
    rescue ArgumentError, TypeError
        render json: { error: 'Invalid date format' }, status: :bad_request
    end

    def fill_missing_date_ranges(start_date, end_date)
        earliest = Movie.minimum(:release_date)
        latest = Movie.maximum(:release_date)

        return fetch_movies(start_date, end_date) if Movie.none?

        fetch_movies(start_date, earliest - 1.day) if start_date < earliest
        fetch_movies(latest + 1.day, end_date) if end_date > latest
    end

    def fetch_movies(start_date, end_date)
        return if start_date > end_date

        begin
            service = TmdbService.new
            movies_data = service.search_by_date_range(start_date, end_date)
            movies_data.each do |data|
                begin
                    Movie.save_from_data(data)
                rescue ActiveRecord::RecordInvalid => e
                    Rails.logger.warn "Could not save movie (tmdb_id: #{data[:tmdb_id]}): #{e.message}"
                end
            end
        rescue StandardError => e
            Rails.logger.error "An unexpected error occurred in fetch_movies: #{e.message}"
            raise
        end
    end
end
