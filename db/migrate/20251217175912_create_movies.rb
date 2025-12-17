class CreateMovies < ActiveRecord::Migration[8.1]
  def change
    create_table :movies do |t|
      t.integer :tmdb_id, null: false
      t.string :title, null: false
      t.date :release_date
      t.text :overview
      t.string :poster_path
      t.decimal :popularity, precision: 10, scale: 2

      t.timestamps

    end

    # Manually adding contrains and indexes for better performance
    add_index :movies, :tmdb_id, unique: true # prevent duplicates
    add_index :movies, :release_date # will be queried often
  end
end
