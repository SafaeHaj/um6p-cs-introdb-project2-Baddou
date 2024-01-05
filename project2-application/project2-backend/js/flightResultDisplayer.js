document.addEventListener("DOMContentLoaded", function () {
    displayFlights(flightsData);
});

function formatTime(hour, minute) {
    return `${hour.toString().padStart(2, '0')}:${minute.toString().padStart(2, '0')}`;
}

function displayFlights(flights) {
    const ticketContainer = document.getElementById('bigContainer');
    flights.forEach(flight => {
        const flightContainer = document.createElement('div');
        flightContainer.classList.add('flight');

        const departureTime = new Date(flight.departureTime);
        const hour = departureTime.getHours();
        const minute = departureTime.getMinutes();

        flightContainer.innerHTML = `        
                <div class="depdest-time">
                    <p class="depdest" id="departure">${flight.departure}</p>
                    <p class="time">${formatTime(hour, minute)}</p>
                    <p class="depdest" id="destination">${flight.destination}</p>
                    <p class="class"> ${boarding_class}</p>
                    <p class="seatsLeft"> ${flight.seats_left} </p>
                </div>
                <div class="airline">
                    <p>${flight.airline}</p>
                    <p class="priceContainer">${flight.price} $</p>
                </div>
        `;

        flightContainer.addEventListener('click', function () {
            window.location.href = `details.view.php?fid=${flight.fid}&passengers=${passenger_count}&flightClass=${boarding_class}`;
        });

        ticketContainer.appendChild(flightContainer);
    });
}