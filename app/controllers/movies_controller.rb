class MoviesController < ApplicationController
    def search
        start_date = Date.parse(params[:start_date]) rescue nil
        end_date = Date.parse(params[:end_date]) rescue nil

        return unless start_date && end_date

        cached_movies = Movie.cached_search(start_date, end_date)

        return fetch_and_cache_movies(start_date, end_date) if !cached_movies.any?

        cached_dates = cached_movies.pluck(:release_date).uniq.to_a
        earliest_release_date = cached_dates[0]
        latest_release_date = cached_dates[-1]

        if start_date < earliest_release_date
            fetch_and_cache_movies(start_date, earliest_release_date)
        end

        if end_date > latest_release_date
            fetch_and_cache_movies(latest_release_date, end_date)
        end

        cached_movies.sort_by(&:popularity).first(20)
    end

    private

    def fetch_and_cache_movies(start_date, end_date)
        service = TmdbService.new
        movies_data = service.search_by_date_range(start_date, end_date)

        movies_data.map do |movie_data|
            Movie.save_from_data(movie_data)
        end
    end
end
