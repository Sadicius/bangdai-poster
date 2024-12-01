import { fetchNui } from './fetchNui.js';

export class Poster {
    constructor() {
        this.container = document.querySelector('.poster-container');
        this.image = document.querySelector('.poster-image');
        this.setupEventListeners();
    }

    setupEventListeners() {
        window.addEventListener('message', this.handleMessage.bind(this));
        document.addEventListener('keydown', this.handleKeydown.bind(this));
        this.image.addEventListener('load', this.handleImageLoad.bind(this));
    }

    handleMessage(event) {
        const { action, ...data } = event.data;
        
        switch(action) {
            case "open":
                this.open(data);
                break;
            case "close":
                this.close();
                break;
        }
    }

    handleKeydown(event) {
        const closeKeys = [27, 8, 9]; // ESC, Backspace, TAB
        if (closeKeys.includes(event.keyCode)) {
            this.close();
        }
    }

    handleImageLoad() {
        const aspectRatio = this.image.naturalWidth / this.image.naturalHeight;
        
        if (aspectRatio > 1) {
            // Landscape orientation
            this.container.style.width = '85vh';
            this.container.style.height = `${85/aspectRatio}vh`;
        } else {
            // Portrait orientation
            this.container.style.width = `${55*aspectRatio}vh`;
            this.container.style.height = '85vh';
        }
        
        this.fadeIn(this.container);
    }

    open(data) {
        if (!data.url) {
            console.error('Error: No URL provided for the poster');
            return;
        }
        this.image.src = data.url;
    }

    close() {
        this.fadeOut(this.container);
        fetchNui('CloseDocument');
    }

    fadeIn(element, duration = 150) {
        element.style.display = 'block';
        element.style.opacity = '0';
        
        let opacity = 0;
        const increment = 0.1;
        const interval = duration / (1 / increment);
        
        const animation = setInterval(() => {
            opacity += increment;
            
            if (opacity >= 1) {
                element.style.opacity = '1';
                clearInterval(animation);
                return;
            }
            
            element.style.opacity = opacity.toString();
        }, interval);
    }

    fadeOut(element, duration = 150) {
        let opacity = 1;
        const decrement = 0.1;
        const interval = duration / (1 / decrement);
        
        const animation = setInterval(() => {
            opacity -= decrement;
            
            if (opacity <= 0) {
                element.style.opacity = '0';
                element.style.display = 'none';
                clearInterval(animation);
                return;
            }
            
            element.style.opacity = opacity.toString();
        }, interval);
    }
}