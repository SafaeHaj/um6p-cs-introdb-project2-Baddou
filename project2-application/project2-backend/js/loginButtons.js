var modal = document.querySelector('.modal');
var signup_returnTimeInput = document.querySelector('.signup-form');
var login_returnTimeInput = document.querySelector('.login-form');

document.getElementById('registration_btn').addEventListener('click', function () {
    modal.classList.remove('hidden');
    signup_returnTimeInput.classList.remove('hidden');
});

document.getElementById('login_btn').addEventListener('click', function () {
    modal.classList.remove('hidden');
    login_returnTimeInput.classList.remove('hidden');
});

