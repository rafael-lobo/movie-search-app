class Movie < ApplicationRecord
    validates :tmdb_id, presence: true, uniqueness: true
    validates :title, presence: true

    def poster_url
        return nil unless poster_path
        "https://image.tmdb.org/t/p/w500#{poster_path}"
    end
end
