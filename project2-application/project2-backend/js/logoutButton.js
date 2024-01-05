document.getElementById('logout_btn').addEventListener('click', function () {
    fetch('/project2-backend/includes/Controllers/logout.controller.php', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'logout_btn=1',
    }).then(response => {
        window.location.href = response.url;
    }) 
});
