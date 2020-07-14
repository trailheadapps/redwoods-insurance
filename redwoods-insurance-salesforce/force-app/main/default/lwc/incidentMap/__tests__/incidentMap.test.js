import { createElement } from 'lwc';
import IncidentMap from 'c/incidentMap';
import { getRecord } from 'lightning/uiRecordApi';
import { registerLdsTestWireAdapter } from '@salesforce/sfdx-lwc-jest';

const getRecordAdapter = registerLdsTestWireAdapter(getRecord);
const mockMapMarkers = require('./data/mockMapMarkers.json');

describe('c-incident-map', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    beforeEach(() => {});

    it('does not render the map component when no map markers are set', () => {
        // Create initial element
        const element = createElement('c-incident-map', {
            is: IncidentMap
        });
        document.body.appendChild(element);

        const mapEl = element.shadowRoot.querySelector('lightning-card');
        expect(mapEl).toBe(null);
    });

    it('renders the map compoent when the wire adapter generates a map marker object', () => {
        // Create initial element
        const element = createElement('c-incident-map', {
            is: IncidentMap
        });
        document.body.appendChild(element);
        getRecordAdapter.emit(mockMapMarkers);

        return Promise.resolve().then(() => {
            //const mapEl = element.shadowRoot.querySelector('lightning-card');
            const mapEl = element.shadowRoot
                .querySelector('lightning-card')
                .querySelector('lightning-map');
            expect(mapEl).not.toBe(null);
        });
    });

    it('does not render the map when an error occurs', () => {
        // Create initial element
        const element = createElement('c-incident-map', {
            is: IncidentMap
        });
        document.body.appendChild(element);
        getRecordAdapter.error();

        const mapEl = element.shadowRoot.querySelector('lightning-card');
        expect(mapEl).toBe(null);
    });
});
