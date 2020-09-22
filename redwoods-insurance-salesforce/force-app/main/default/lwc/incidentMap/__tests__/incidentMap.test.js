import { createElement } from 'lwc';
import IncidentMap from 'c/incidentMap';
import { getRecord } from 'lightning/uiRecordApi';
import { registerLdsTestWireAdapter } from '@salesforce/sfdx-lwc-jest';

const getRecordAdapter = registerLdsTestWireAdapter(getRecord);
const mockMapMarkers = require('./data/mockMapMarkers.json');
const mockRecordId = '5001700000pJRRTAA4';

describe('c-incident-map', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('invokes the wire adapter with default properties', () => {
        // Create initial element
        const element = createElement('c-incident-map', {
            is: IncidentMap
        });
        element.recordId = mockRecordId;
        document.body.appendChild(element);

        return Promise.resolve().then(() => {
            expect(getRecordAdapter.getLastConfig()).toEqual({
                recordId: mockRecordId,
                fields: [
                    'Case.Incident_Location__Latitude__s',
                    'Case.Incident_Location__Longitude__s'
                ]
            });
        });
    });

    it('does not render the map component when no map markers are set', () => {
        // Create initial element
        const element = createElement('c-incident-map', {
            is: IncidentMap
        });
        document.body.appendChild(element);

        const mapEl = element.shadowRoot.querySelector('lightning-map');
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
            const mapEl = element.shadowRoot.querySelector('lightning-map');
            expect(mapEl).not.toBe(null);
            expect(mapEl.mapMarkers).toEqual([
                { location: { Latitude: '51.524723', Longitude: '6.922778' } }
            ]);
        });
    });

    it('does not render the map when an error occurs', () => {
        // Create initial element
        const element = createElement('c-incident-map', {
            is: IncidentMap
        });
        document.body.appendChild(element);
        getRecordAdapter.error();

        const cardEl = element.shadowRoot.querySelector('lightning-card');
        expect(cardEl).toBe(null);
    });

    it('is accessible', () => {
        const element = createElement('c-incident-map', {
            is: IncidentMap
        });

        document.body.appendChild(element);
        getRecordAdapter.emit(mockMapMarkers);

        return Promise.resolve().then(() => expect(element).toBeAccessible());
    });
});
