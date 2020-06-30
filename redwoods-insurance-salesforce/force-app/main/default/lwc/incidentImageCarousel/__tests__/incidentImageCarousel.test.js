import { createElement } from 'lwc';
import IncidentImageCarousel from 'c/incidentImageCarousel';

describe('c-incident-image-carousel', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('renders no pictures by default', () => {
        // Create initial element
        const element = createElement('c-incident-image-carousel', {
            is: IncidentImageCarousel
        });
        document.body.appendChild(element);

        const labelElement = element.shadowRoot.querySelector('p');
        expect(labelElement.textContent).toContain('no images');
    });
});
