let airportsMap = {};
let searchResultsVisible = false;

const fetchData = async () => {
    try {
        const response = await fetch('./assets/airports.json');
        const airportsArray = await response.json();

        airportsMap = airportsArray.reduce((acc, airport) => {
            acc[airport.toLowerCase()] = airport;
            return acc;
        }, {});
    } catch (error) {
        console.error('Error fetching data:', error);
    }
};

document.addEventListener("DOMContentLoaded", function () {
    const searchInputDeparture = document.getElementById("departure");
    const searchInputDestination = document.getElementById("destination");

    getSuggestions(searchInputDeparture);
    getSuggestions(searchInputDestination);
});

function getSuggestions(searchInput) {
    const searchResults = searchInput.nextElementSibling;

    const debounce = (func, delay) => {
        let timeoutId;
        return (...args) => {
            clearTimeout(timeoutId);
            timeoutId = setTimeout(() => {
                func.apply(this, args);
            }, delay);
        };
    };

    const displayResults = (results) => {
        if (results.length > 0) {
            searchResults.innerHTML = results.map(result =>
                `<a href="#" class="suggestion">${result}</a>`
            ).join("");
            searchResults.style.display = "block";
            searchResultsVisible = true;

            // Add click event listener to suggestions
            searchResults.querySelectorAll('.suggestion').forEach(suggestion => {
                suggestion.addEventListener('click', (event) => {
                    // Write suggestion into the input
                    searchInput.value = event.target.textContent;
                    // Hide the search results
                    searchResults.style.display = "none";
                    searchResultsVisible = false;
                });
            });
        } else {
            searchResults.innerHTML = "";
            searchResults.style.display = "none";
            searchResultsVisible = false;
        }
    };

    const handleInput = () => {
        const searchTerm = searchInput.value.toLowerCase();
        const matchingAirports = Object.keys(airportsMap)
            .filter(airportName => airportName.includes(searchTerm))
            .map(airportName => airportsMap[airportName]);

        const top5Airports = matchingAirports.slice(0, 5);
        displayResults(top5Airports);
    };

    const handleDocumentClick = (event) => {
        if (!searchResults.contains(event.target) && !searchInput.contains(event.target)) {
            searchResults.style.display = "none";
            searchResultsVisible = false;
        }
    };

    searchInput.addEventListener("input", debounce(handleInput, 300));
    document.addEventListener("click", handleDocumentClick);

    fetchData();
}