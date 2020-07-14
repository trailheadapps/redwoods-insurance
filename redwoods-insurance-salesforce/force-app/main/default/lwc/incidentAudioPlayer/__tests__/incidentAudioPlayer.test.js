import { createElement } from 'lwc';
import IncidentAudioPlayer from 'c/incidentAudioPlayer';
import {
    registerApexTestWireAdapter,
    registerLdsTestWireAdapter
} from '@salesforce/sfdx-lwc-jest';
import { getRecord } from 'lightning/uiRecordApi';
import { getAudio } from '@salesforce/apex/IncidentController.findRelatedFiles';

const mockAudioFile = require('./data/mockAudioFile.json');
const getRelatedAudioAdapter = registerApexTestWireAdapter(getAudio);
const getRecordAdapter = registerLdsTestWireAdapter(getRecord);

describe('c-incident-audio-player', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('does not show the player when no audio file is provided.', () => {
        // Create initial element
        const element = createElement('c-incident-audio-player', {
            is: IncidentAudioPlayer
        });
        document.body.appendChild(element);

        const labelElement = element.shadowRoot.querySelector('p');
        expect(labelElement.textContent).toContain(
            'There are currently no audio files for this case.'
        );
    });

    it('displays the audio player when the wire adapter returns an audio file', () => {
        const element = createElement('c-incident-audio-player', {
            is: IncidentAudioPlayer
        });
        document.body.appendChild(element);

        getRecordAdapter.emit('mockRecordId');
        getRelatedAudioAdapter.emit(mockAudioFile);

        return Promise.resolve().then(() => {
            const audioPlayerEl = element.shadowRoot.querySelector('audio');
            expect(audioPlayerEl).not.toBe(null);
        });
    });

    it('does not display the player when the wire adapter returns something other than an array', () => {
        const element = createElement('c-incident-audio-player', {
            is: IncidentAudioPlayer
        });
        document.body.appendChild(element);

        getRecordAdapter.emit('mockRecordId');
        // force the wire adapter mock to emit an obj instead of an array
        getRelatedAudioAdapter.emit({});

        return Promise.resolve().then(() => {
            const labelElement = element.shadowRoot.querySelector('p');
            expect(labelElement.textContent).toContain(
                'There are currently no audio files for this case.'
            );
        });
    });
});
