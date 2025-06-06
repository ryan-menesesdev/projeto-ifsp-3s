document.addEventListener('DOMContentLoaded', () => {
    const carouselSlides = document.querySelector('.carousel-slides');
    const slides = document.querySelectorAll('.carousel-slide');
    const prevBtn = document.getElementById('prevBtn');
    const nextBtn = document.getElementById('nextBtn');
    const playPauseBtn = document.getElementById('playPauseBtn');
    const playPauseIcon = document.getElementById('playPauseIcon');
    const carouselDotsContainer = document.getElementById('carouselDots');

    let currentSlideIndex = 0;
    const totalSlides = slides.length;
    let autoPlayInterval;
    let isAutoPlaying = true;
    const autoPlayDelay = 3000; 

    function showSlide(index) {
        if (index >= totalSlides) {
            currentSlideIndex = 0; 
        } else if (index < 0) {
            currentSlideIndex = totalSlides - 1;
        } else {
            currentSlideIndex = index;
        }

        carouselSlides.style.transform = `translateX(-${currentSlideIndex * 100}%)`;

        updateDots();
    }

    function nextSlide() {
        showSlide(currentSlideIndex + 1);
    }

    function prevSlide() {
        showSlide(currentSlideIndex - 1);
    }

    function startAutoPlay() {
        if (!isAutoPlaying) {
            autoPlayInterval = setInterval(nextSlide, autoPlayDelay);
            isAutoPlaying = true;
            playPauseIcon.classList.remove('fa-play');
            playPauseIcon.classList.add('fa-pause');
        }
    }

    function stopAutoPlay() {
        if (isAutoPlaying) {
            clearInterval(autoPlayInterval);
            isAutoPlaying = false;
            playPauseIcon.classList.remove('fa-pause');
            playPauseIcon.classList.add('fa-play');
        }
    }

    function createDots() {
        carouselDotsContainer.innerHTML = ''; 
        for (let i = 0; i < totalSlides; i++) {
            const dot = document.createElement('div');
            dot.classList.add('dot');
            dot.dataset.index = i; 
            dot.addEventListener('click', () => {
                stopAutoPlay(); 
                showSlide(i);
            });
            carouselDotsContainer.appendChild(dot);
        }
    }

    function updateDots() {
        const dots = document.querySelectorAll('.dot');
        dots.forEach((dot, index) => {
            if (index === currentSlideIndex) {
                dot.classList.add('active');
            } else {
                dot.classList.remove('active');
            }
        });
    }

    prevBtn.addEventListener('click', () => {
        stopAutoPlay(); 
        prevSlide();
    });

    nextBtn.addEventListener('click', () => {
        stopAutoPlay(); 
        nextSlide();
    });

    playPauseBtn.addEventListener('click', () => {
        if (isAutoPlaying) {
            stopAutoPlay();
        } else {
            startAutoPlay();
        }
    });

    createDots(); 
    showSlide(currentSlideIndex); 
    autoPlayInterval = setInterval(nextSlide, autoPlayDelay);
});
