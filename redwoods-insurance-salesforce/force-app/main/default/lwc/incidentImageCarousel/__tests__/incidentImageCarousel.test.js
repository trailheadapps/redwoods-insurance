import { createElement } from 'lwc';
import IncidentImageCarousel from 'c/incidentImageCarousel';
import { registerApexTestWireAdapter } from '@salesforce/sfdx-lwc-jest';
import { getRecord } from 'lightning/uiRecordApi';
import { getRelatedPictures } from '@salesforce/apex/IncidentController.findRelatedFiles';
import { registerLdsTestWireAdapter } from '@salesforce/sfdx-lwc-jest';

// Realistic data with two images.
const mockTwoImages = require('./data/twoImages.json');
// Register an Apex Wire adapter.
const getRelatedPicturesAdapter = registerApexTestWireAdapter(
    getRelatedPictures
);

const getRecordAdapter = registerLdsTestWireAdapter(getRecord);

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
        expect(labelElement.textContent).toContain(
            'There are currently no images of damage for this case.'
        );
    });

    it('renders two pictures when the wire mock returns two', () => {
        // Create initial element
        const element = createElement('c-incident-image-carousel', {
            is: IncidentImageCarousel
        });
        document.body.appendChild(element);

        // Emit data from @wire
        getRecordAdapter.emit('mockRecordId');
        getRelatedPicturesAdapter.emit(mockTwoImages);

        return Promise.resolve().then(() => {
            const imageEls = element.shadowRoot.querySelectorAll(
                'lightning-carousel-image'
            );
            expect(imageEls.length).toEqual(mockTwoImages.length);
        });
    });

    it('renders no pictures when the wire adapter returns something other than an aray', () => {
        // Create initial element
        const element = createElement('c-incident-image-carousel', {
            is: IncidentImageCarousel
        });
        document.body.appendChild(element);

        // Emit data from @wire
        getRecordAdapter.emit('mockRecordId');
        // forcibly emit an object, instead of an array.
        getRelatedPicturesAdapter.emit({});

        return Promise.resolve().then(() => {
            const labelElement = element.shadowRoot.querySelector('p');
            expect(labelElement.textContent).toContain(
                'There are currently no images of damage for this case.'
            );
        });
    });
});
