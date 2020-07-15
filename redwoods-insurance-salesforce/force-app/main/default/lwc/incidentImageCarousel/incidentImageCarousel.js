import { LightningElement, wire, api } from 'lwc';
import getRelatedPictures from '@salesforce/apex/IncidentController.findRelatedFiles';

export default class IncidentImageCarousel extends LightningElement {
    @api recordId;
    urls;

    @wire(getRelatedPictures, {
        caseId: '$recordId',
        fileType: 'IMAGE'
    })
    wiredPictures(pictures) {
        if (pictures.data) {
            const files = pictures.data;
            if (Array.isArray(files) && files.length) {
                this.urls = files.map(
                    (file) =>
                        '/sfc/servlet.shepherd/version/download/' + file.Id
                );
            } else {
                this.urls = null;
            }
        }
    }
}
