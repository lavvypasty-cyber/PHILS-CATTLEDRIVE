// ========================================
// CATTLE DRIVE UI - JavaScript
// ========================================

let selectedDestination = null;
let selectedReward = 0;

const menu = document.getElementById('cattle-menu');
const prompt = document.getElementById('prompt');
const toast = document.getElementById('complete-toast');

// -------------------------------------------------------------
// Message handling
// -------------------------------------------------------------
window.addEventListener('message', (e) => {
    const { action, data } = e.data;

    switch (action) {
        case 'setPrompt':
            if (data.text && data.text.length > 0) {
                document.getElementById('prompt-text').textContent = data.text;
                prompt.classList.remove('hidden');
            } else {
                prompt.classList.add('hidden');
            }
            break;

        case 'showMenu':
            showMenu(data.destinations, data.startIndex);
            break;

        case 'driveComplete':
            toast.classList.remove('hidden');
            setTimeout(() => toast.classList.add('hidden'), 4000);
            break;
    }
});

// -------------------------------------------------------------
// Menu logic
// -------------------------------------------------------------
function showMenu(destinations, startIndex) {
    menu.classList.remove('hidden');
    selectedDestination = null;
    selectedReward = 0;

    const rewardDisplay = document.getElementById('reward-display');
    if (rewardDisplay) {
        rewardDisplay.textContent = 'Select destination';
    }

    const list = document.getElementById('destination-list');
    list.innerHTML = '';

    destinations.forEach((dest, i) => {
        const item = document.createElement('div');
        item.className = 'destination-item';
        item.innerHTML = `
            <div class="dest-icon">
                <i class="fas fa-location-dot"></i>
            </div>
            <div class="dest-info">
                <div class="dest-name">${dest.label}</div>
                <div class="dest-reward">$${dest.reward}</div>
            </div>
        `;
        item.addEventListener('click', () => {
            document.querySelectorAll('.destination-item').forEach(el =>
                el.classList.remove('selected'));
            item.classList.add('selected');
            selectedDestination = i + 1;
            selectedReward = dest.reward;

            if (rewardDisplay) {
                rewardDisplay.textContent = '$' + dest.reward;
            }

            // Start drive on selection
            menu.classList.add('hidden');
            fetch(`https://phils-cattledrive/startDrive`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ destination: selectedDestination })
            });
        });
        list.appendChild(item);
    });
}

// -------------------------------------------------------------
// Close button
// -------------------------------------------------------------
document.getElementById('close-menu').addEventListener('click', () => {
    menu.classList.add('hidden');
    fetch(`https://phils-cattledrive/closeUI`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
});

// -------------------------------------------------------------
// ESC closes menu
// -------------------------------------------------------------
document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape' && !menu.classList.contains('hidden')) {
        menu.classList.add('hidden');
        fetch(`https://phils-cattledrive/closeUI`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
        });
    }
});
