const searchForm = document.getElementById('searchForm');
const startDateInput = document.getElementById('startDate');
const endDateInput = document.getElementById('endDate');
const loadingDiv = document.getElementById('loading');
const errorDiv = document.getElementById('error');
const resultsInfoDiv = document.getElementById('resultsInfo');
const resultsDiv = document.getElementById('results');

function initializeDates() {
  const today = new Date();
  const thirtyDaysAgo = new Date(today);
  thirtyDaysAgo.setDate(today.getDate() - 30);
  
  endDateInput.value = today.toISOString().split('T')[0];
  startDateInput.value = thirtyDaysAgo.toISOString().split('T')[0];
}

function showLoading() {
  loadingDiv.style.display = 'block';
  errorDiv.style.display = 'none';
  resultsInfoDiv.style.display = 'none';
  resultsDiv.innerHTML = '';
}

function showError(message) {
  loadingDiv.style.display = 'none';
  errorDiv.textContent = message;
  errorDiv.style.display = 'block';
  resultsInfoDiv.style.display = 'none';
  resultsDiv.innerHTML = '';
}

function showResults(data) {
  loadingDiv.style.display = 'none';
  errorDiv.style.display = 'none';
  
  if (data.movies.length === 0) {
    resultsInfoDiv.style.display = 'none';
    resultsDiv.innerHTML = '<p class="no-results">No movies found in this date range.</p>';
    return;
  }

  const totalText = data.total_available > 0 ? `- ${data.total_available} total available` : '';
  resultsInfoDiv.textContent = `Showing ${data.count} most popular movies ${totalText}`;
  resultsInfoDiv.style.display = 'block';
  
  resultsDiv.innerHTML = data.movies.map(createMovieCard).join('');
}

function createMovieCard(movie) {
  const posterUrl = movie.poster_url || 'https://fireteller.com.au/wp-content/uploads/2020/09/Poster_Not_Available2.jpg';
  const overview = movie.overview || 'No description available.';
  const releaseDate = movie.release_date ? new Date(movie.release_date).toLocaleDateString() : 'Unknown';
  
  return `
    <div class="movie-card">
      <img src="${posterUrl}" alt="${movie.title}" class="movie-poster" loading="lazy">
      <div class="movie-info">
        <h3 class="movie-title">${movie.title}</h3>
        <p class="movie-date">📅 ${releaseDate}</p>
        <p class="movie-overview">${truncate(overview, 200)}</p>
      </div>
    </div>
  `;
}

function truncate(text, maxLength) {
  if (text.length <= maxLength) return text;
  return text.substr(0, maxLength) + '...';
}

async function handleSearch(e) {
  e.preventDefault();
  
  const startDate = startDateInput.value;
  const endDate = endDateInput.value;
  
  if (!startDate || !endDate) {
    showError('Please select both start and end dates.');
    return;
  }
  
  if (new Date(startDate) > new Date(endDate)) {
    showError('Start date must be before end date.');
    return;
  }
  
  showLoading();

  try {
    const response = await fetch(`/movies/search?start_date=${startDate}&end_date=${endDate}`);
    const data = await response.json();
    
    if (!response.ok) {
      throw new Error(data.error || 'Failed to fetch movies');
    }
    
    showResults(data);
  } catch (error) {
    showError(error.message || 'An error occurred while searching for movies.');
  }
}

searchForm.addEventListener('submit', handleSearch);

initializeDates();
