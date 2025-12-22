class Movie < ApplicationRecord
    validates :tmdb_id, presence: true, uniqueness: true
    validates :title, presence: true

    def self.save_from_data(movie_data)
        find_or_create_by!(tmdb_id: movie_data[:tmdb_id]) do |movie|
            movie.title = movie_data[:title]
            movie.release_date = movie_data[:release_date]
            movie.overview = movie_data[:overview]
            movie.poster_path = movie_data[:poster_path]
            movie.popularity = movie_data[:popularity]
        end
    end

    def self.cached_search(start_date, end_date)
        where(release_date: start_date..end_date).order(release_date: :asc)
    end

    def poster_url
        return nil unless poster_path
        "https://image.tmdb.org/t/p/w500#{poster_path}"
    end
end
