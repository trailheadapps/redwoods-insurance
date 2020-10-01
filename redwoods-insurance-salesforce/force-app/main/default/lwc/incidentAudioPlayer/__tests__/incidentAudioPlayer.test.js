import { createElement } from 'lwc';
import IncidentAudioPlayer from 'c/incidentAudioPlayer';
import { registerApexTestWireAdapter } from '@salesforce/sfdx-lwc-jest';
import { getAudio } from '@salesforce/apex/IncidentController.findRelatedFiles';

const mockAudioFile = require('./data/mockAudioFile.json');
const multipleMockAudioFiles = require('./data/multipleMockAudioFiles.json');
const getRelatedAudioAdapter = registerApexTestWireAdapter(getAudio);
const mockRecordId = '5001700000pJRRUAA4';

describe('c-incident-audio-player', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('invokes the wire adapter with default properties', () => {
        // Create initial element
        const element = createElement('c-incident-audio-player', {
            is: IncidentAudioPlayer
        });
        element.recordId = mockRecordId;
        document.body.appendChild(element);

        return Promise.resolve().then(() => {
            expect(getRelatedAudioAdapter.getLastConfig()).toEqual({
                caseId: mockRecordId,
                fileType: 'AUDIO'
            });
        });
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

        getRelatedAudioAdapter.emit(mockAudioFile);

        return Promise.resolve().then(() => {
            const audioPlayerEl = element.shadowRoot.querySelector('audio');
            expect(audioPlayerEl).not.toBe(null);
            expect.stringMatching(audioPlayerEl.src, /mockAudioFile.Id$/);
        });
    });

    it('displays one audio player for each file the wire adapter returns', () => {
        const element = createElement('c-incident-audio-player', {
            is: IncidentAudioPlayer
        });
        document.body.appendChild(element);

        getRelatedAudioAdapter.emit(multipleMockAudioFiles);

        return Promise.resolve().then(() => {
            const audioPlayerEls = element.shadowRoot.querySelectorAll('audio');
            expect(audioPlayerEls.length).toEqual(
                multipleMockAudioFiles.length
            );
            audioPlayerEls.forEach(function (value, index) {
                expect.stringMatching(
                    audioPlayerEls[index].src,
                    /multipeMockAudioFiles[index].Id$/
                );
            });
        });
    });

    it('does not display the player when the wire adapter returns something other than an array', () => {
        const element = createElement('c-incident-audio-player', {
            is: IncidentAudioPlayer
        });
        document.body.appendChild(element);

        // force the wire adapter mock to emit an obj instead of an array
        getRelatedAudioAdapter.emit({});

        return Promise.resolve().then(() => {
            const labelElement = element.shadowRoot.querySelector('p');
            expect(labelElement.textContent).toContain(
                'There are currently no audio files for this case.'
            );
        });
    });

    it('is accessible when multiple audio files', () => {
        const element = createElement('c-incident-audio-player', {
            is: IncidentAudioPlayer
        });

        document.body.appendChild(element);
        getRelatedAudioAdapter.emit(multipleMockAudioFiles);

        return Promise.resolve().then(() => expect(element).toBeAccessible());
    });

    it('is accessible when no audio files', () => {
        const element = createElement('c-incident-audio-player', {
            is: IncidentAudioPlayer
        });

        document.body.appendChild(element);

        // force the wire adapter mock to emit an obj instead of an array
        getRelatedAudioAdapter.emit({});

        return Promise.resolve().then(() => expect(element).toBeAccessible());
    });
});
