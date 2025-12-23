# Movie Search Application

A web application that allows users to search for movies released within a specific date range using the TMDb API. Results are cached locally to minimize external API calls.

## 🚀 Live Demo

[Live Application URL](https://movie-search-app-bnth.onrender.com)

## 📋 Features

- Search movies by date range
- Display movie title, release date, popularity score, description, and poster
- Smart caching system (stores results in local database)
- No repeated API calls for the same date ranges
- Clean interface

## 🛠️ Technology Stack

**Backend:**
- Ruby on Rails 7 (API mode)
- SQLite3 database
- TMDb API for movie data

**Frontend:**
- Vanilla JavaScript (no frameworks)
- HTML5 & CSS3
- Fetch API for backend communication

## 📦 Setup Instructions

### Prerequisites

- Ruby 3.0+
- Rails 7.0+
- TMDb API key (free from themoviedb.org)

### Local Development

1. **Clone the repository:**
```bash
git clone https://github.com/rafael-lobo/movie-search-app.git
cd movie-search-app
```

2. **Install dependencies:**
```bash
bundle install
```

3. **Set up environment variables:**
```bash
# Create .env file in root directory
echo "TMDB_API_KEY=your_api_key_here" > .env
```

4. **Set up database:**
```bash
rails db:migrate
```

5. **Start the server:**
```bash
rails server
```

6. **Visit the application:**
Open `http://localhost:3000` in your browser

## 🏗️ Design Decisions & Trade-offs

### Architecture

**Rails API + Vanilla JS Frontend**
- **Why:** Simplicity and fast development. No build process needed.
- **Trade-off:** Less interactive than using frameworks, but works well for this use case.

### Caching Strategy

**Database-backed caching by date range**
- **How it works:** When a date range is searched, the **top-20 most popular movies** in that range are stored. Future queries check the database first before calling the TMDb API.
- **Why:** Dramatically reduces API calls. TMDb free tier allows 1000 requests/day. The top-20 most popular movies for a given date range, which are in the first page of the TMDb API response, are enough for this exercise.
- **Trade-off:** Doesn't update if movie data changes on TMDb. For a production app, could get all movies,  from all pages, from a given date range.

### Database Choice

**SQLite3**
- **Why:** Zero configuration, perfect for this scale, free hosting compatible.
- **Trade-off:** Not suitable for high-concurrency production apps. For scaling, would migrate to PostgreSQL.

### Data Model

**Single `movies` table with indexes**
```ruby
- tmdb_id (indexed, unique)
- title
- release_date (indexed for date range queries)
- overview
- poster_path
- popularity
```
- **Why:** Simple, normalized, efficient queries.
- **Indexes:** Speed up lookups by tmdb_id and date range searches.

### Error Handling

- API errors show accurate messages
- Frontend validates input before submission
- Backend validates and sanitizes inputs

### Code Organization

**Service Object Pattern**
- `TmdbService`: Handles all external API communication
- **Why:** Separates concerns, makes testing easier, keeps controllers thin

## 🎯 What I'd Improve With More Time

1. **Pagination**
   - Current: Shows first page of results (~20 movies)
   - Improvement: Implement infinite scroll or page numbers

2. **Search Filters**
   - Add genre, rating, language filters
   - Sort options (rating, popularity, date)

3. **Testing**
   - Add RSpec for backend
   - Add JavaScript tests for frontend

4. **Movie Details Modal**
   - Click card to see full details, cast, trailer

5. **Performance**
   - Background job for fetching multiple pages
   - Redis for session-based caching

6. **User Accounts**
   - Save favorite movies
   - Personal watchlists

7. **Better Frontend Framework**
   - Migrate to React for better state management

8.  **Analytics**
    - Track popular searches
    - Monitor API usage

## 🤖 AI Tool Usage

I used Claude and Gemini to:
- Generate boilerplate code structure, mostly on the front-end
- Review my code and suggest optimisations
- Debug CORS configuration issues
- Improve CSS responsive design and HTML structure
- Generate this README's initial structure

All final code was reviewed and understood before implementation

## 📝 API Endpoints

### GET /movies/search

Search for movies by date range.

**Parameters:**
- `start_date` (required): Date in YYYY-MM-DD format
- `end_date` (required): Date in YYYY-MM-DD format

**Response:**
```json
{
  "movies": [
    {
      "id": 1,
      "tmdb_id": 12345,
      "title": "Example Movie",
      "release_date": "2024-01-15",
      "overview": "Movie description...",
      "poster_url": "https://image.tmdb.org/...",
      "popularity": 123.45
    }
  ],
  "count": 20,
  "total_available": 150
}
```

## 🚢 Deployment

Deployed on Render with:
- SQLite database persisted to volume
- Environment variables configured in platform dashboard
- Automatic deploys from main branch


## 🙏 Acknowledgments

- Movie data provided by [TMDb](https://www.themoviedb.org/)
- Built as part of Gruvi's technical assessment