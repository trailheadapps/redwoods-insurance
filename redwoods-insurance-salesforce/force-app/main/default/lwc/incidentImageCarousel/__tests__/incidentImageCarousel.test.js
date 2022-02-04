import { createElement } from 'lwc';
import IncidentImageCarousel from 'c/incidentImageCarousel';
import { getRelatedPictures } from '@salesforce/apex/IncidentController.findRelatedFiles';

// Realistic data with two images.
const mockTwoImages = require('./data/twoImages.json');
const mockRecordId = '5001700000pJRRTAA4';

// Mock findRelatedFiles Apex wire adapter
jest.mock(
    '@salesforce/apex/IncidentController.findRelatedFiles',
    () => {
        const {
            createApexTestWireAdapter
        } = require('@salesforce/sfdx-lwc-jest');
        return {
            default: createApexTestWireAdapter(jest.fn())
        };
    },
    { virtual: true }
);

describe('c-incident-image-carousel', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('invokes the wire adapter with default properties', () => {
        // Create initial element
        const element = createElement('c-incident-image-carousel', {
            is: IncidentImageCarousel
        });
        element.recordId = mockRecordId;
        document.body.appendChild(element);

        return Promise.resolve().then(() => {
            expect(getRelatedPictures.getLastConfig()).toEqual({
                caseId: mockRecordId,
                fileType: 'IMAGE'
            });
        });
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
        getRelatedPictures.emit(mockTwoImages);
        // getRelatedPicturesAdapter.emit(mockTwoImages);

        return Promise.resolve().then(() => {
            const imageEls = element.shadowRoot.querySelectorAll(
                'lightning-carousel-image'
            );
            expect(imageEls.length).toEqual(mockTwoImages.length);
            imageEls.forEach(function (value, index) {
                expect.stringMatching(
                    imageEls[index].src,
                    /mockTwoImages[index].Id$/
                );
            });
        });
    });

    it('renders no pictures when the wire adapter returns something other than an aray', () => {
        // Create initial element
        const element = createElement('c-incident-image-carousel', {
            is: IncidentImageCarousel
        });
        document.body.appendChild(element);

        // forcibly emit an object, instead of an array.
        getRelatedPictures.emit({});

        return Promise.resolve().then(() => {
            const labelElement = element.shadowRoot.querySelector('p');
            expect(labelElement.textContent).toContain(
                'There are currently no images of damage for this case.'
            );
        });
    });

    it('is accessible when one or more urls present', () => {
        const element = createElement('c-incident-image-carousel', {
            is: IncidentImageCarousel
        });

        document.body.appendChild(element);

        // Emit data from @wire
        getRelatedPictures.emit(mockTwoImages);

        return Promise.resolve().then(() => expect(element).toBeAccessible());
    });

    it('is accessible when no urls', () => {
        const element = createElement('c-incident-image-carousel', {
            is: IncidentImageCarousel
        });

        document.body.appendChild(element);

        // forcibly emit an object, instead of an array.
        getRelatedPictures.emit({});

        return Promise.resolve().then(() => expect(element).toBeAccessible());
    });
});
