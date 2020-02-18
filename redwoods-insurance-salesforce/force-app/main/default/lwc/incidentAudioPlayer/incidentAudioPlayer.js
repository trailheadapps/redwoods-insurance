import { LightningElement, wire, api } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getAudio from '@salesforce/apex/IncidentController.findRelatedFiles';

export default class IncidentAudioPlayer extends LightningElement {
    @api recordId;
    urls;
    audioFiles;

    @wire(getRecord, {
        recordId: '$recordId'
    })
    kase;

    @wire(getAudio, {
        caseId: '$recordId',
        fileType: 'AUDIO'
    })
    wiredPictures(audioFiles) {
        this.audioFiles = audioFiles;
        if (audioFiles.data) {
            const files = audioFiles.data;
            if (Array.isArray(files) && files.length) {
                this.urls = files.map(
                    file => '/sfc/servlet.shepherd/version/download/' + file.Id
                );
            } else {
                this.urls = null;
            }
        }
    }
}
