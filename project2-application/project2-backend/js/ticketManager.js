const formContainer = document.querySelector('.passenger-forms');
const formDataArray = [];

function showForm() {
    formContainer.classList.toggle('hidden')
}

document.querySelectorAll('.show-fcid').forEach( (fcf) => {
    fcf.addEventListener('click', function(){
        showFCField(fcf);
    })
});

function showFCField(fcf){
    const parentContainer = fcf.closest('.passenger-information');
    parentContainer.querySelector('.fcfield').classList.toggle('hidden');
}

function calculateTicketPrice(ticketClass, fidelityCardType, basePrice) {
    let fidelityDiscount;
    let ticketPrice;

    const fidelityCard = {
        'None': 0,
        'Explorer': 10,
        'Gold': 30,
        'Platinum': 40,
        'Silver': 20
    };
    fidelityDiscount = fidelityCard[fidelityCardType] / 100;


    switch (ticketClass) {
        case 'businessClass':
            ticketPrice = basePrice - basePrice * (fidelityDiscount + 0.1);
            break;
        case 'firstClass':
            ticketPrice = basePrice - basePrice * (fidelityDiscount + 0.2);
            break;
        case 'premiumEconomy':
            ticketPrice = basePrice - basePrice * (fidelityDiscount + 0.05);
            break;
        default:
            ticketPrice = basePrice - basePrice * fidelityDiscount;
    }

    return ticketPrice;
}

function isFormFilled(form) {
    if (form) {
        const formElements = form.elements;

        for (let i = 0; i < formElements.length; i++) {
            const element = formElements[i];

            if (element.required && element.value.trim() === '') {
                return false;
            }
        }

        return true;
    }

    return false;
}

function addToPassengerList(array) {
    passengerList = document.getElementById("passenger-list");
    passengerList.innerHTML += `<div class="passenger">
                <p class="first-name">${array['firstName']}</p>
                <p class="last-name">${array['lastName']}</p>
                <p class="passportID">${array['passportId']}</p>
                <p class="cin">${array['cin']}</p>
                <button class="delete">x</button>
            </div>`;
}

document.addEventListener('DOMContentLoaded', () => {
    const deleteButtons = document.querySelectorAll('.delete');

    deleteButtons.forEach(button => {
        button.addEventListener('click', () => {
            button.closest('.passenger').remove();
        });
    });
});

document.querySelectorAll('.save').forEach((btn) => {
    btn.addEventListener('click', function () {
        const parentContainer = this.closest('.passenger-information');

        if (!isFormFilled(parentContainer)){
            return;
        }

        const getInputValue = (name) => {
            const input = parentContainer.querySelector(`[name="${name}"]`);
            return input ? input.value : null;
        };

        const inputValues = {};
        const inputFieldNames = ['firstName', 'lastName', 'phoneNumber', 'passportId', 'cin', 'birthdate', 'fcid', 'fidelityCardType'];
        
        inputFieldNames.forEach((name) => {
            const value = getInputValue(name);
            inputValues[name] = value;
        });

        formDataArray.push(inputValues)
        addToPassengerList(inputValues)

        const priceElement = document.getElementById('price');
        const ticketPriceData = calculateTicketPrice(boarding_class, inputValues["fidelityCardType"], flight_price);
        priceElement.textContent = (parseFloat(priceElement.textContent) + ticketPriceData) + ' $';
        
        parentContainer.remove();
    })
});

document.getElementById("confirm").addEventListener('click', () => {
    const requestData = {
        passengers: formDataArray,
    };
    const url = '../Controllers/tickets.controller.php?fid=' + fid + '&flightClass=' + boarding_class;  

    const params = {
        method: "POST",
        headers: {
            "Content-Type": "application/json; charset=utf-8"
        },
        body: JSON.stringify(requestData)
    };
      
    fetch(url, params)
    .then(response => response.json())
    .then(data => {
        console.log("Response:", data);
        if (data.success) {
            const priceElement = document.getElementById('price');
            window.location.href = data.redirectUrl + "&price=" + priceElement.textContent;
        } else {
            alert("An error has occured please try again later.");
        }
    })
    .catch(error => {
        console.error("Error:", error);
    });
});
