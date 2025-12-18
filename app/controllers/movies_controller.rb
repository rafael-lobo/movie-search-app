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

        cached_movies.sort_by(&:popularity)
        render_movies(cached_movies.first(20))
    end

    private

    def fetch_and_cache_movies(start_date, end_date)
        service = TmdbService.new
        movies_data = service.search_by_date_range(start_date, end_date)

        movies = movies_data.map do |movie_data|
            Movie.save_from_data(movie_data)
        end

        render_movies(movies)
    end

     def render_movies(movies)
        render json: {
            movies: movies.map { |m| format_movie(m) },
            count: movies.size,
        }
    end

    def format_movie(movie)
        {
            id: movie.id,
            tmdb_id: movie.tmdb_id,
            title: movie.title,
            release_date: movie.release_date,
            overview: movie.overview,
            poster_url: movie.poster_url,
            popularity: movie.popularity
        }
    end
end
